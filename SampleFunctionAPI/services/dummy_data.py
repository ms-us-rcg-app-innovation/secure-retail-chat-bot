data = {
    "recent_sales": [
      {
        "id": 1,
        "item": 'shirt',
        "size": 'large',
        "color": 'blue',
        "price": '13.99'

      },
      {
        "id": 2,
        "item": 'shirt',
        "size": 'large',
        "color": 'orange',
        "price": '15.99'
      },
      {
        "id": 3,
        "item": 'jeans',
        "size": 'small',
        "color": 'green',
        "price": '19.99'
      },
      {
        "id": 4,
        "item": 'skirt',
        "size": 'medium',
        "color": 'green',
        "price": '33.99'
      },
      {
        "id": 5,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '33.99'
      },
      {
        "id": 6,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '33.99'
      },
      {
        "id": 7,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '33.99'
      },
      {
        "id": 8,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '15.99'
      },
      {
        "id": 9,
        "item": 'skirt',
        "size": 'xlarge',
        "color": 'blue',
        "price": '18.30'
      },
      {
        "id": 10,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '23.99'
      },
      {
        "id": 11,
        "item": 'skirt',
        "size": 'medium',
        "color": 'blue',
        "price": '23.99'
      },
      {
        "id": 12,
        "item": 'long dress',
        "size": 'small',
        "color": 'blue',
        "price": '33.99'
      },
    ]
}

def get_top_seller_type_uni(query):
  top_seller_type = []
  for x in data['recent_sales']:
    top_seller_type.append(x[query])

  d={}
  for i in range(len(top_seller_type)):
    x=top_seller_type[i]
    c=0
    for j in range(i,len(top_seller_type)):
      if top_seller_type[j]==top_seller_type[i]:
        c=c+1
    count=dict({x:c})
    if x not in d.keys():
      d.update(count)
  return(d)
  

def get_top_sellers(search_for):
  top_seller =get_top_seller_type_uni(search_for)
  return top_seller
