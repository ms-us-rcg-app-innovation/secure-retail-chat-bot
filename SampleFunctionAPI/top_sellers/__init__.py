import logging, json

import azure.functions as func
from services.data_service import list_top_sellers


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
  
    try:
        # message = req.get_json()
        search_for = req.params.get('search_for')
    except:
        message = 'no request body has been passed'
        return func.HttpResponse(json.dumps(message), headers={"content-type": "application/json"})

    if search_for not in ['item','size','color','price']:
        return func.HttpResponse(json.dumps("invalid search option, please select item, size or color"), headers={"content-type": "application/json"})

    data = list_top_sellers(search_for)

    value = {
        search_for: data,
    }

    print(value)

    return func.HttpResponse(json.dumps(value), headers={"content-type": "application/json"})
