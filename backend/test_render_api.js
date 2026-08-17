const fs = require('fs');

async function getAuthToken() {
  try {
    const googleServices = JSON.parse(fs.readFileSync('../android/app/google-services.json', 'utf8'));
    const apiKey = googleServices.client[0].api_key[0].current_key;
    
    // 1. Sign up a random test user to get an ID token
    const testEmail = `test_${Date.now()}@example.com`;
    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: testEmail,
          password: 'password123',
          returnSecureToken: true
        })
      }
    );
    
    const data = await response.json();
    if (!response.ok) throw new Error(JSON.stringify(data));
    
    const idToken = data.idToken;
    console.log('Got ID Token:', idToken.substring(0, 20) + '...');
    
    // 2. Test the Render API
    console.log('Testing Render API...');
    const apiResponse = await fetch(
      'https://scrollify-backend.onrender.com/api/users/check-username?username=test',
      {
        headers: { Authorization: `Bearer ${idToken}` }
      }
    );
    
    console.log('Render API Status:', apiResponse.status);
    const apiData = await apiResponse.json();
    console.log('Render API Data:', apiData);
    
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

getAuthToken();
