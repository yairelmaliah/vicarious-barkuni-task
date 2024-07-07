from flask import jsonify, render_template

def configure_routes(app):

    @app.route('/')
    def home():
        return render_template('index.html')

    @app.route('/pods')
    def pods():
        # Placeholder for Kubernetes API interaction
        return jsonify({"message": "Pods will be displayed here"})

    @app.route('/health')
    def health_check():
        return jsonify({"status": "healthy"}), 200
