from flask import Flask, render_template, request
import json

app = Flask(__name__)

# Add cache control headers to prevent caching
@app.after_request
def add_header(response):
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response

@app.route('/', methods=['GET', 'POST'])
def pension_calculator():
    table_data = []
    total_contributions = 0  # Initialize total_contributions
    initial_investment = 0
    total_earned = 0

    if request.method == 'POST':
        # Get initial investment
        initial_investment_input = request.form.get('initial_investment')
        P = 0  # Default value
        if initial_investment_input:
            try:
                P = float(initial_investment_input)
                initial_investment = P
            except ValueError:
                return render_template('index.html', result="Invalid initial investment amount.", table_data=table_data)

        # Get monthly contribution
        monthly_contribution_input = request.form.get('monthly_contribution')
        monthly_contribution = 0  # Default value
        annual_contribution = 0  # Default value
        if monthly_contribution_input:
            try:
                monthly_contribution = float(monthly_contribution_input)
                annual_contribution = monthly_contribution * 12
            except ValueError:
                return render_template('index.html', result="Invalid monthly contribution amount.", table_data=table_data)

        # Get annual interest rate
        annual_interest_rate_input = request.form.get('annual_interest_rate')
        r = 0  # Default value
        if annual_interest_rate_input:
            try:
                r = float(annual_interest_rate_input) / 100
                if r <= 0:
                    return render_template('index.html', result="Annual interest rate must be greater than 0.", table_data=table_data)
            except ValueError:
                return render_template('index.html', result="Invalid annual interest rate.", table_data=table_data)

        # Get compounding frequency
        try:
            compounding_frequency = int(request.form['compounding_frequency'])
            if compounding_frequency <= 0:
                return render_template('index.html', result="Compounding frequency must be greater than zero.", table_data=table_data)
        except (ValueError, KeyError):
            return render_template('index.html', result="Invalid compounding frequency.", table_data=table_data)

        # Get investment period
        try:
            t = int(request.form['investment_period'])
        except ValueError:
            return render_template('index.html', result="Invalid investment period.", table_data=table_data)

        # Get inflation adjustment and inflation rate
        inflation_rate = 0
        if request.form.get('inflation_adjustment'):
            inflation_rate_input = request.form.get('inflation_rate')
            if inflation_rate_input:
                try:
                    inflation_rate = float(inflation_rate_input) / 100
                except ValueError:
                    return render_template('index.html', result="Invalid inflation rate.", table_data=table_data)

        # Calculate future value of initial investment and contributions
        FV_initial = P * (1 + r / compounding_frequency) ** (compounding_frequency * t)

        FV_contributions = 0
        for month in range(1, t * 12 + 1):
            FV_contributions += monthly_contribution * (1 + r / compounding_frequency) ** (compounding_frequency * ((t * 12 - month + 1) / 12))

        final_sum = FV_initial + FV_contributions
        result = f"The future value of your investment is: ${final_sum:,.2f}"
        if inflation_rate > 0:
            adjusted_final_sum = final_sum / ((1 + inflation_rate) ** t)
            result += f" (Adjusted for inflation: ${adjusted_final_sum:,.2f})"

        # Calculate total contributions
        total_contributions = P + annual_contribution * t

        # Calculate total earned money
        total_earned = final_sum - total_contributions

        # Generate table data
        accumulated_value = P
        for year in range(1, t + 1):
            start_sum = accumulated_value
            for month in range(1, 12 + 1):
                accumulated_value = (accumulated_value + monthly_contribution) * (1 + r / compounding_frequency) ** (compounding_frequency / 12)
            interest_income = accumulated_value - start_sum - annual_contribution
            end_sum = accumulated_value
            table_data.append((year, f"${start_sum:,.2f}", f"${interest_income:,.2f}", f"${annual_contribution:,.2f}", f"${end_sum:,.2f}"))

        # Prepare data for the pie chart
        pie_data = {
            'labels': ['Initial Investment', 'Total Earned', 'Total Contributions'],
            'data': [initial_investment, total_earned, total_contributions],
            'backgroundColor': [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)'
            ],
            'borderColor': [
                'rgba(255, 99, 132, 1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)'
            ],
            'borderWidth': 1
        }

        # Convert pie_data to JSON
        pie_data_json = json.dumps(pie_data)

        return render_template('index.html', result=result, table_data=table_data, total_contributions=f"${total_contributions:,.2f}", total_earned=f"${total_earned:,.2f}", pie_data=pie_data_json)

    return render_template('index.html', result="", table_data=table_data)

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)