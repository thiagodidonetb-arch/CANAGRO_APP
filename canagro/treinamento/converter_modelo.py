
from pathlib import Path

import torch
from torch import nn
from torchvision import models

PASTA = Path(
    r"C:\Users\Windows\Desktop\Canagro_1\canagro\treinamento\resultado"
)

ARQUIVO_PTH = PASTA / "canagro_modelo.pth"
ARQUIVO_ONNX = PASTA / "canagro_modelo.onnx"

print("Carregando o modelo CANAGRO...")

checkpoint = torch.load(
    ARQUIVO_PTH,
    map_location="cpu",
    weights_only=True,
)

classes = checkpoint["classes"]
tamanho = checkpoint["tamanho_imagem"]

modelo = models.resnet18(weights=None)
modelo.fc = nn.Linear(modelo.fc.in_features, len(classes))
modelo.load_state_dict(checkpoint["estado_modelo"])
modelo.eval()

entrada = torch.randn(1, 3, tamanho, tamanho)

print("Convertendo para ONNX...")

torch.onnx.export(
    modelo,
    entrada,
    str(ARQUIVO_ONNX),
    input_names=["imagem"],
    output_names=["resultados"],
    opset_version=17,
    dynamo=False,
)

print("\nConversão concluída!")
print("Arquivo:", ARQUIVO_ONNX)
print("Categorias:")
for classe in classes:
    print("-", classe)
