#renv::install("coolbutuseless/rllama")

library(rllama)

# gguf is quantized format
# another version needed to convert gguf to binary

ctx <- llama_init("/shared/llam-test/llama.cpp/models/llama-2-70b/ggml-model-q4_0.gguf") # quantized 70b model
llama(ctx, prompt = "The apple said to the banana", n = 400)

