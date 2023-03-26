import os
import logging

from dotenv import load_dotenv
from azure.functions import HttpRequest, HttpResponse

load_dotenv()

api_key = os.environ.get("API_KEY")

def main(req: HttpRequest) -> HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    if req.headers.get("api_key") == api_key:
        return HttpResponse("Hello, world!")
    else:
        return HttpResponse("Invalid API key This is ConvertToSharedMailbox function.", status_code=403)
