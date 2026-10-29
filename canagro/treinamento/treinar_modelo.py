
import json
import random
from pathlib import Path

import numpy as np
import torch
from PIL import Image
from sklearn.model_selection import train_test_split
from torch import nn
from torch.utils.data import Dataset, DataLoader
from torchvision import models, transforms
from torchvision.models import ResNet18_Weights


# ==========================================
# CONFIGURAÇÕES DO CANAGRO
# ==========================================

PASTA_PROJETO = Path(
    r"C:\Users\Windows\Desktop\Canagro_1\canagro"
)

PASTA_IMAGENS = PASTA_PROJETO / "assets" / "imagens"
PASTA_SAIDA = PASTA_PROJETO / "treinamento" / "resultado"

PASTA_SAIDA.mkdir(parents=True, exist_ok=True)

SEMENTE = 42
EPOCAS = 10
TAMANHO_LOTE = 8
TAMANHO_IMAGEM = 224

random.seed(SEMENTE)
np.random.seed(SEMENTE)
torch.manual_seed(SEMENTE)

DISPOSITIVO = torch.device("cpu")

EXTENSOES = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

CATEGORIAS = {
    "cana_saudavel": "Cana saudável",
    "Broca da cana-de-açúcar": "Broca-da-cana",
    "Cigarrinha da cana": "Cigarrinha-da-cana",
    "Carvão da cana-de-açúcar": "Carvão da cana",
    "Mosaico da cana-de-açúcar": "Mosaico da cana",
}


# ==========================================
# LOCALIZAR E VALIDAR AS IMAGENS
# ==========================================

def localizar_imagens():
    arquivos = []

    pasta_saudavel = PASTA_IMAGENS / "cana_saudavel"

    if pasta_saudavel.exists():
        for arquivo in pasta_saudavel.rglob("*"):
            if arquivo.is_file() and arquivo.suffix.lower() in EXTENSOES:
                arquivos.append((arquivo, "Cana saudável"))

    for grupo in ["pragas", "doencas"]:
        pasta_grupo = PASTA_IMAGENS / grupo

        if not pasta_grupo.exists():
            continue

        for pasta_categoria in pasta_grupo.iterdir():
            if not pasta_categoria.is_dir():
                continue

            nome = CATEGORIAS.get(pasta_categoria.name)

            if nome is None:
                print("Categoria não reconhecida:", pasta_categoria.name)
                continue

            for arquivo in pasta_categoria.rglob("*"):
                if arquivo.is_file() and arquivo.suffix.lower() in EXTENSOES:
                    arquivos.append((arquivo, nome))

    imagens_validas = []
    erros = []

    print("\nVerificando imagens...")

    for caminho, categoria in arquivos:
        try:
            with Image.open(caminho) as imagem:
                imagem.verify()

            imagens_validas.append((caminho, categoria))

        except Exception:
            erros.append(str(caminho))

    print("Imagens encontradas:", len(arquivos))
    print("Imagens válidas:", len(imagens_validas))
    print("Imagens com erro:", len(erros))

    if erros:
        for erro in erros:
            print("Arquivo com problema:", erro)

    if len(imagens_validas) == 0:
        raise RuntimeError("Nenhuma imagem válida foi encontrada.")

    return imagens_validas


# ==========================================
# SEPARAR TREINAMENTO, VALIDAÇÃO E TESTE
# ==========================================

class ImagensCana(Dataset):
    def __init__(self, itens, transformacao):
        self.itens = itens
        self.transformacao = transformacao

    def __len__(self):
        return len(self.itens)

    def __getitem__(self, indice):
        caminho, rotulo = self.itens[indice]

        with Image.open(caminho) as imagem:
            imagem = imagem.convert("RGB")

        imagem = self.transformacao(imagem)

        return imagem, rotulo


def preparar_dados(imagens, nomes_classes):
    indices = np.arange(len(imagens))
    rotulos = np.array([item[1] for item in imagens])

    treino, restante = train_test_split(
        indices,
        test_size=0.30,
        random_state=SEMENTE,
        stratify=rotulos,
    )

    validacao, teste = train_test_split(
        restante,
        test_size=0.50,
        random_state=SEMENTE,
        stratify=rotulos[restante],
    )

    dados_treino = [imagens[i] for i in treino]
    dados_validacao = [imagens[i] for i in validacao]
    dados_teste = [imagens[i] for i in teste]

    transformacao_treino = transforms.Compose([
        transforms.Resize((TAMANHO_IMAGEM, TAMANHO_IMAGEM)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(
            brightness=0.15,
            contrast=0.15,
            saturation=0.10,
        ),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225],
        ),
    ])

    transformacao_avaliacao = transforms.Compose([
        transforms.Resize((TAMANHO_IMAGEM, TAMANHO_IMAGEM)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225],
        ),
    ])

    treino_dataset = ImagensCana(
        dados_treino, transformacao_treino
    )

    validacao_dataset = ImagensCana(
        dados_validacao, transformacao_avaliacao
    )

    teste_dataset = ImagensCana(
        dados_teste, transformacao_avaliacao
    )

    treino_loader = DataLoader(
        treino_dataset,
        batch_size=TAMANHO_LOTE,
        shuffle=True,
        num_workers=0,
    )

    validacao_loader = DataLoader(
        validacao_dataset,
        batch_size=TAMANHO_LOTE,
        shuffle=False,
        num_workers=0,
    )

    teste_loader = DataLoader(
        teste_dataset,
        batch_size=TAMANHO_LOTE,
        shuffle=False,
        num_workers=0,
    )

    print("\nSeparação dos dados:")
    print("Treinamento:", len(treino_dataset))
    print("Validação:", len(validacao_dataset))
    print("Teste:", len(teste_dataset))

    return treino_loader, validacao_loader, teste_loader


# ==========================================
# CRIAR O MODELO
# ==========================================

def criar_modelo(numero_classes):
    print("\nCarregando ResNet18 pré-treinada...")
    print("Na primeira execução, será necessário baixar os pesos.")

    pesos = ResNet18_Weights.DEFAULT
    modelo = models.resnet18(weights=pesos)

    # Inicialmente, manteremos as camadas anteriores congeladas.
    for parametro in modelo.parameters():
        parametro.requires_grad = False

    # Treinar a última camada para as categorias do CANAGRO.
    modelo.fc = nn.Linear(
        modelo.fc.in_features,
        numero_classes,
    )

    return modelo.to(DISPOSITIVO)


# ==========================================
# TREINAR E AVALIAR
# ==========================================

def avaliar(modelo, carregador, criterio):
    modelo.eval()

    perda_total = 0.0
    acertos = 0
    total = 0

    with torch.no_grad():
        for imagens, rotulos in carregador:
            imagens = imagens.to(DISPOSITIVO)
            rotulos = rotulos.to(DISPOSITIVO)

            saidas = modelo(imagens)
            perda = criterio(saidas, rotulos)

            perda_total += perda.item() * imagens.size(0)

            previsoes = saidas.argmax(dim=1)
            acertos += (previsoes == rotulos).sum().item()
            total += rotulos.size(0)

    perda_media = perda_total / max(total, 1)
    acuracia = acertos / max(total, 1)

    return perda_media, acuracia


def treinar():
    imagens = localizar_imagens()

    nomes_classes = sorted(set(item[1] for item in imagens))
    mapa_classes = {
        nome: indice for indice, nome in enumerate(nomes_classes)
    }

    imagens_numeradas = [
        (caminho, mapa_classes[categoria])
        for caminho, categoria in imagens
    ]

    if len(nomes_classes) < 2:
        raise RuntimeError("São necessárias pelo menos duas categorias.")

    print("\nCategorias:")
    for nome in nomes_classes:
        quantidade = sum(1 for _, categoria in imagens if categoria == nome)
        print(f"- {nome}: {quantidade} imagens")

    treino, validacao, teste = preparar_dados(
        imagens_numeradas, nomes_classes
    )

    modelo = criar_modelo(len(nomes_classes))

    criterio = nn.CrossEntropyLoss()

    otimizador = torch.optim.Adam(
        modelo.fc.parameters(),
        lr=0.001,
    )

    melhor_acuracia = -1.0
    caminho_modelo = PASTA_SAIDA / "canagro_modelo.pth"

    print("\nIniciando treinamento na CPU...")
    print("Isso pode demorar. Não feche o terminal.")

    for epoca in range(EPOCAS):
        modelo.train()

        perda_treino = 0.0
        total_treino = 0

        for imagens_lote, rotulos_lote in treino:
            imagens_lote = imagens_lote.to(DISPOSITIVO)
            rotulos_lote = rotulos_lote.to(DISPOSITIVO)

            otimizador.zero_grad()

            saidas = modelo(imagens_lote)
            perda = criterio(saidas, rotulos_lote)

            perda.backward()
            otimizador.step()

            perda_treino += perda.item() * imagens_lote.size(0)
            total_treino += rotulos_lote.size(0)

        perda_treino /= max(total_treino, 1)

        perda_validacao, acuracia_validacao = avaliar(
            modelo, validacao, criterio
        )

        print(
            f"Época {epoca + 1}/{EPOCAS} | "
            f"perda treino: {perda_treino:.4f} | "
            f"perda validação: {perda_validacao:.4f} | "
            f"acurácia validação: {acuracia_validacao:.1%}"
        )

        if acuracia_validacao > melhor_acuracia:
            melhor_acuracia = acuracia_validacao

            torch.save(
                {
                    "estado_modelo": modelo.state_dict(),
                    "classes": nomes_classes,
                    "tamanho_imagem": TAMANHO_IMAGEM,
                },
                caminho_modelo,
            )

    # Carregar o melhor modelo encontrado na validação.
    checkpoint = torch.load(
        caminho_modelo,
        map_location=DISPOSITIVO,
        weights_only=True,
    )

    modelo.load_state_dict(checkpoint["estado_modelo"])

    perda_teste, acuracia_teste = avaliar(
        modelo, teste, criterio
    )

    caminho_classes = PASTA_SAIDA / "classes.json"

    with open(caminho_classes, "w", encoding="utf-8") as arquivo:
        json.dump(
            nomes_classes,
            arquivo,
            ensure_ascii=False,
            indent=2,
        )

    resultados = {
        "total_imagens": len(imagens),
        "categorias": nomes_classes,
        "acuracia_validacao": melhor_acuracia,
        "acuracia_teste": acuracia_teste,
        "perda_teste": perda_teste,
        "observacao": (
            "Resultado experimental. Não representa garantia "
            "de precisão em fotos reais de campo."
        ),
    }

    with open(
        PASTA_SAIDA / "resultados.json",
        "w",
        encoding="utf-8",
    ) as arquivo:
        json.dump(
            resultados,
            arquivo,
            ensure_ascii=False,
            indent=2,
        )

    print("\nTREINAMENTO CONCLUÍDO!")
    print(f"Acurácia na validação: {melhor_acuracia:.1%}")
    print(f"Acurácia no teste: {acuracia_teste:.1%}")
    print("\nArquivos salvos em:")
    print(PASTA_SAIDA)
    print("\nAtenção: teste o modelo com fotos novas de campo antes de confiar nos diagnósticos.")


if __name__ == "__main__":
    try:
        treinar()
    except Exception as erro:
        print("\nO treinamento não pôde ser concluído.")
        print("Erro:", repr(erro))
        raise
