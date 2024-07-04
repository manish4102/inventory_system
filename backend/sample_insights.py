from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/analyze-data', methods=['POST'])
def analyze_data():
    try:
        data = request.json.get('data')

        insights = {}

        for sale in data:
            for product in sale['products']:
                product_name = product['name']
                quantity = product['quantity']
                price = product['price']
                total_price = product['totalPrice']

                profit_per_unit = price - (total_price / quantity)
                total_profit = profit_per_unit * quantity

                if product_name in insights:
                    insights[product_name]['quantity'] += quantity
                    insights[product_name]['total_profit'] += total_profit
                else:
                    insights[product_name] = {
                        'quantity': quantity,
                        'average_price': price,
                        'total_profit': total_profit
                    }

        return jsonify({'insight': insights})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 400
