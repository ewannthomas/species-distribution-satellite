import torch

print("CUDA available:", torch.cuda.is_available())
print("GPU Name:", torch.cuda.get_device_name(0))
print("PyTorch CUDA Version:", torch.version.cuda)
