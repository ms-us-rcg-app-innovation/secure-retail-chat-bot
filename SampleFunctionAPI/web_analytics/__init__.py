import logging, json

import azure.functions as func
from services.data_service import list_time_spent


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    search_for = req.params.get('search_for')
    
    data = list_time_spent(search_for)

    return func.HttpResponse(json.dumps(data), headers={"content-type": "application/json"})
