import os
from flask import Flask, send_from_directory, jsonify

app = Flask(__name__, static_folder="static", static_url_path="")

@app.route("/api/hello")
def hello():
    return jsonify({"message": "Hello from Flask backend!"})

IS_DEV = os.environ.get("MYAPP_DEV") == "1"

if not IS_DEV:
    @app.route("/")
    def serve_index():
        return send_from_directory(app.static_folder, "index.html")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=IS_DEV)
