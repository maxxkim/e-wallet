const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios'); 

admin.initializeApp();

exports.payIn = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).send({ status: 'error', description: 'Method Not Allowed' });
    }

    const {
        merchantId,
        transactionId,
        country,
        currency,
        payMethod,
        documentId,
        amount,
        email,
        name,
        timestamp,
        payinExpirationTime,
        url_OK,
        url_ERROR,
        objData
    } = req.body;

    /*if (!merchantId || !transactionId || !amount || !email || !name) {
        return res.status(400).send({ 
            status: 'error', 
            description: 'Missing required fields' 
        });
    }*/

    const requestData = {
        merchantId,
        transactionId,
        country,
        currency,
        payMethod,
        documentId,
        amount,
        email,
        name,
        timestamp,
        payinExpirationTime,
        url_OK,
        url_ERROR,
        objData
    };

    try {
        const response = await axios.post('https://api-dot-zippy-dev-payments.rj.r.appspot.com/pay', requestData, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        return res.status(200).send(response.data);
    } catch (error) {
        console.error('Error making payment request:', error);
        return res.status(500).send({ 
            status: 'error', 
            description: 'Internal Server Error' 
        });
    }
});