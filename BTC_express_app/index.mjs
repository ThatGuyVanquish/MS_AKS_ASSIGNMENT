import express from 'express';
import fetch from 'node-fetch';

const app = express();

let currentBTCPrice;
let avgPrice;
let previousPrices = [];

// Function to fetch Bitcoin price from CoinGecko API
const fetchBitcoinPrice = async (print = true) => {
    try {
        const url = `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd`;
        const response = await fetch(url);
        const data = await response.json();
		if (data.status) {
			console.error('Error fetching Bitcoin price:', data.status.error_message);
			return false;
		}
        const bitcoinPrice = data.bitcoin.usd; // Bitcoin price in USD
        if (print) console.log(`Bitcoin price: $${bitcoinPrice}`);
        currentBTCPrice = bitcoinPrice;
        if (print) previousPrices.push(currentBTCPrice);
        if (previousPrices.length === 10) {
            avgPrice = previousPrices.reduce((accumulator, currentValue) => accumulator + currentValue, 0) / 10;
            if (print) console.log(`Average price for the past 10 minutes: ${avgPrice}`);
            previousPrices = [];
        }
		return true;
    } catch (error) {
        console.error('Error fetching Bitcoin price:', error);
		return false;
    }
};

// Health check endpoint
app.get('/service-a/healthz', (req, res) => {
    res.status(200).send('OK');
});

// Readiness check endpoint
app.get('/service-a/readiness', async (req, res) => {
	const canFetch = await fetchBitcoinPrice(false);
    if (canFetch)
		res.status(200).send('OK');
	else res.status(400).send('ERROR');

})

app.get('/service-a', (req, res) => {
    const now = new Date();
    res.json({ Time: now, Price: currentBTCPrice, Average_Price: avgPrice });
});

// Fetch Bitcoin price every 60 seconds
fetchBitcoinPrice();
setInterval(fetchBitcoinPrice, 60000);

const PORT = 80;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
