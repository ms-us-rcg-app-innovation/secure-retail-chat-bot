from services.dummy_data import get_top_sellers

from services.dummy_data_web import web_analytics, get_visitors_by_country, purchase_stats

def list_top_sellers(search_for):
    return get_top_sellers(search_for)

def list_time_spent(search_for):
    if search_for == 'time_spent':
        return web_analytics()
    if search_for == 'visitor_country':
        return get_visitors_by_country('userlocation')
    if search_for == 'purchase_stats':
        return purchase_stats()
    
