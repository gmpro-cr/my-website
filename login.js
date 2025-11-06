// Sample credit card data
const sampleCards = [
    {
        id: 1,
        bank: "HDFC Bank",
        cardNumber: "4532 **** **** 1234",
        totalDue: 45678,
        minimumDue: 5000,
        dueDate: "2025-11-15",
        creditLimit: 200000,
        availableCredit: 154322,
        transactions: [
            { name: "Amazon.in", date: "2025-11-01", amount: 3499 },
            { name: "Swiggy", date: "2025-11-02", amount: 850 },
            { name: "Netflix", date: "2025-11-03", amount: 649 },
            { name: "Reliance Digital", date: "2025-11-04", amount: 12500 },
            { name: "Uber", date: "2025-11-05", amount: 380 }
        ]
    },
    {
        id: 2,
        bank: "SBI Card",
        cardNumber: "5412 **** **** 5678",
        totalDue: 23450,
        minimumDue: 2500,
        dueDate: "2025-11-18",
        creditLimit: 150000,
        availableCredit: 126550,
        transactions: [
            { name: "Myntra", date: "2025-10-28", amount: 4200 },
            { name: "BigBasket", date: "2025-10-30", amount: 2800 },
            { name: "BookMyShow", date: "2025-11-01", amount: 650 },
            { name: "Zomato", date: "2025-11-03", amount: 1200 }
        ]
    },
    {
        id: 3,
        bank: "ICICI Bank",
        cardNumber: "6011 **** **** 9012",
        totalDue: 67890,
        minimumDue: 7500,
        dueDate: "2025-11-12",
        creditLimit: 300000,
        availableCredit: 232110,
        transactions: [
            { name: "Flipkart", date: "2025-10-25", amount: 15600 },
            { name: "Apple Store", date: "2025-10-27", amount: 28999 },
            { name: "Petrol Pump", date: "2025-10-29", amount: 3500 },
            { name: "Starbucks", date: "2025-11-02", amount: 750 },
            { name: "DMart", date: "2025-11-04", amount: 5200 }
        ]
    }
];

// Initialize sample data in localStorage
function initializeData() {
    if (!localStorage.getItem('creditCards')) {
        localStorage.setItem('creditCards', JSON.stringify(sampleCards));
    }
}

// Handle login form submission
document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const errorMessage = document.getElementById('errorMessage');

    // Demo authentication
    if (username === 'demo' && password === 'demo123') {
        // Initialize data
        initializeData();

        // Set logged in status
        localStorage.setItem('isLoggedIn', 'true');

        // Redirect to cards page
        window.location.href = 'cards.html';
    } else {
        errorMessage.textContent = 'Invalid username or password';
        setTimeout(() => {
            errorMessage.textContent = '';
        }, 3000);
    }
});

// Check if already logged in
if (localStorage.getItem('isLoggedIn') === 'true') {
    window.location.href = 'cards.html';
}
