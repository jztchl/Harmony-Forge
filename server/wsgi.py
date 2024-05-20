from flask_app import app

# This function creates a callable WSGI application object
def create_wsgi_app():
    return app

# This is the entry point for Waitress, where it calls the create_wsgi_app function
if __name__ == "__main__":
    from waitress import serve
    serve(create_wsgi_app)
