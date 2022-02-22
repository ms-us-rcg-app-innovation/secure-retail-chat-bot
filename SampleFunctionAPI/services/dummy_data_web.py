data = {
    "webstats": [
      {
        "id": 1,
        "timespent": '2',
        "userlocation": 'USA',
        "purchased_items": '4',
        "total_purchase": '133.99'

      },
      {
        "id": 2,
        "timespent": '3',
        "userlocation": 'DENMARK',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 3,
        "timespent": '3',
        "userlocation": 'USA',
        "purchased_items": '1',
        "total_purchase": '33.99'
      },
      {
        "id": 4,
        "timespent": '3',
        "userlocation": 'DENMARK',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 5,
        "timespent": '3',
        "userlocation": 'USA',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 6,
        "timespent": '3',
        "userlocation": 'DENMARK',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 7,
        "timespent": '4',
        "userlocation": 'USA',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 8,
        "timespent": '5',
        "userlocation": 'FINLAND',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 9,
        "timespent": '6',
        "userlocation": 'USA',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 10,
        "timespent": '3',
        "userlocation": 'USA',
        "purchased_items": '2',
        "total_purchase": '59.50'
      },
      {
        "id": 11,
        "timespent": '3',
        "userlocation": 'FRANCE',
        "purchased_items": '1',
        "total_purchase": '12.32'
      },
      {
        "id": 12,
        "timespent": '3',
        "userlocation": 'FRANCE',
        "purchased_items": '0',
        "total_purchase": '0'
      },
      {
        "id": 13,
        "timespent": '5',
        "userlocation": 'FRANCE',
        "purchased_items": '0',
        "total_purchase": '0'
      },
    ]
}

def get_visitors_by_country(query):
  data_stats = []
  for x in data['webstats']:
    data_stats.append(x[query])

  d={}
  for i in range(len(data_stats)):
    x=data_stats[i]
    c=0
    for j in range(i,len(data_stats)):
      if data_stats[j]==data_stats[i]:
        c=c+1
    count=dict({x:c})
    if x not in d.keys():
      d.update(count)

  num_visitors_by_country = {'visitor_country':d}

  return(num_visitors_by_country)
def get_web_stats_time_spent():
  arr = []
  for key in data['webstats']:
    arr.append(float(key['timespent']))

  time_spent_stats = {'time_spent':{
        'max': max(arr),
        'min': min(arr),
        'avg': round(sum(arr) / len(arr), 2),
        'unit': 'minutes',
    }}
  return(time_spent_stats)

def get_web_purchase_stats():
  num_purchases = 0
  avg_purchase_price = 0
  avg_purchase_items = 0
  total_visitors = len(data['webstats'])

  for key in data['webstats']:
    print(key)
    if int(key['purchased_items']) != 0:
      num_purchases = num_purchases + 1
      avg_purchase_price = avg_purchase_price + float(key['total_purchase'])
      avg_purchase_items = avg_purchase_items + int(key['purchased_items'])

  avg_purchase_price = avg_purchase_price/num_purchases
  print(total_visitors,num_purchases,avg_purchase_price,avg_purchase_items)

  get_web_purchase_stats = {'purchase_stats':{
        'total_visitors': total_visitors,
        'number_of_purchases': num_purchases,
        'average_num_of_items_per_purchase': avg_purchase_items,
        'average_purchase_ammount': avg_purchase_price,
    }}
  return(get_web_purchase_stats)

def web_analytics():

  print(get_visitors_by_country('userlocation'))

  return get_web_stats_time_spent()


def purchase_stats():

  return get_web_purchase_stats()
