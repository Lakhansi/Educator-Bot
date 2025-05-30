from flask import Flask, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
import torch

app = Flask(__name__)

MODEL_NAME = "bigcode/starcoderbase-1b"
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Load model with 8-bit quantization
bnb_config = BitsAndBytesConfig(load_in_8bit=True)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, quantization_config=bnb_config)
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    text = data.get("text", "").strip()
    if not text:
        return jsonify({"error": "No input text provided."}), 400

    lower_text = text.lower()
    if "python" in lower_text:
        language = "python"
    elif "java" in lower_text:
        language = "java"
    elif "c++" in lower_text or "cpp" in lower_text:
        language = "cpp"
    elif "c " in lower_text or lower_text.startswith("c program") or "in c" in lower_text:
        language = "c"
    else:
        language = "python"  # Default

    # Prompt
    prompt = (
        f"Explain the following coding problem in a short paragraph. Then, provide a working example code in {language} within triple backticks. Finally, show a very brief example of how to use the code (e.g., a function call or a simple instantiation).\n\n"
        f"Problem: {text}\n\n"
        f"Explanation:\n"
    )

    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

    with torch.no_grad():
        output = model.generate(
            **inputs,
            max_new_tokens=768,
            do_sample=True,
            temperature=0.3,
            top_p=0.85,
            repetition_penalty=1.1,
            eos_token_id=tokenizer.eos_token_id
        )

        response_text = tokenizer.decode(output[0], skip_special_tokens=True).strip()

        explanation = ""
        code = ""
        example = ""

        parts = response_text.split("```")
        if len(parts) > 1:
            explanation = parts[0].split("Explanation:")[-1].strip()
            if len(parts) > 2:
                code_block = parts[1].strip()
                code_lines = code_block.split('\n')

                # ✅ Always remove the first line if it looks like a language label
                if code_lines and code_lines[0].strip().lower() in ["cpp", "c++", "python", "java", "c"]:
                    code = "\n".join(code_lines[1:]).strip()
                else:
                    code = code_block

                # Extract example line
                example_lines = [line.strip() for line in code.split('\n') if line.strip()]
                if example_lines:
                    example = example_lines[0]
            else:
                explanation = response_text.split("Explanation:")[-1].strip()
        else:
            explanation = response_text.split("Explanation:")[-1].strip()


        return jsonify({
            "explanation": explanation.strip(),
            "code": f"```\n{code.strip()}\n```" if code.strip() else "",
            "example": example.strip()
        })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
