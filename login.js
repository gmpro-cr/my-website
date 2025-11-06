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
    // Initialize payment history
    if (!localStorage.getItem('paymentHistory')) {
        localStorage.setItem('paymentHistory', JSON.stringify([]));
    }
}

// Toggle password visibility
function togglePassword() {
    const passwordInput = document.getElementById('password');
    const toggleIcon = document.getElementById('toggleIcon');

    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        toggleIcon.textContent = '🙈';
    } else {
        passwordInput.type = 'password';
        toggleIcon.textContent = '👁️';
    }
}

// Form validation
function validateForm() {
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const usernameError = document.getElementById('username-error');
    const passwordError = document.getElementById('password-error');
    const errorMessage = document.getElementById('errorMessage');

    let isValid = true;

    // Clear previous errors
    usernameError.textContent = '';
    passwordError.textContent = '';
    errorMessage.textContent = '';

    // Validate username
    if (!username) {
        usernameError.textContent = 'Username is required';
        isValid = false;
    } else if (username.length < 3) {
        usernameError.textContent = 'Username must be at least 3 characters';
        isValid = false;
    }

    // Validate password
    if (!password) {
        passwordError.textContent = 'Password is required';
        isValid = false;
    } else if (password.length < 6) {
        passwordError.textContent = 'Password must be at least 6 characters';
        isValid = false;
    }

    return isValid;
}

// Show loading state
function setLoading(isLoading) {
    const loginBtn = document.getElementById('loginBtn');
    const btnText = loginBtn.querySelector('.btn-text');
    const btnLoader = loginBtn.querySelector('.btn-loader');

    if (isLoading) {
        loginBtn.disabled = true;
        btnText.style.display = 'none';
        btnLoader.style.display = 'inline-block';
        loginBtn.style.opacity = '0.7';
    } else {
        loginBtn.disabled = false;
        btnText.style.display = 'inline';
        btnLoader.style.display = 'none';
        loginBtn.style.opacity = '1';
    }
}

// Handle login form submission
document.getElementById('loginForm').addEventListener('submit', async function(e) {
    e.preventDefault();

    // Validate form
    if (!validateForm()) {
        return;
    }

    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const errorMessage = document.getElementById('errorMessage');

    // Show loading state
    setLoading(true);

    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 800));

    // Demo authentication
    if (username === 'demo' && password === 'demo123') {
        // Initialize data
        initializeData();

        // Set logged in status with timestamp
        localStorage.setItem('isLoggedIn', 'true');
        localStorage.setItem('loginTime', new Date().toISOString());
        localStorage.setItem('username', username);

        // Redirect to dashboard
        window.location.href = 'dashboard.html';
    } else {
        setLoading(false);
        errorMessage.textContent = 'Invalid username or password. Please try again.';

        // Shake animation
        errorMessage.style.animation = 'shake 0.5s';
        setTimeout(() => {
            errorMessage.style.animation = '';
        }, 500);
    }
});

// Real-time validation
document.getElementById('username').addEventListener('blur', function() {
    const usernameError = document.getElementById('username-error');
    const username = this.value.trim();

    if (!username) {
        usernameError.textContent = 'Username is required';
    } else if (username.length < 3) {
        usernameError.textContent = 'Username must be at least 3 characters';
    } else {
        usernameError.textContent = '';
    }
});

document.getElementById('password').addEventListener('blur', function() {
    const passwordError = document.getElementById('password-error');
    const password = this.value;

    if (!password) {
        passwordError.textContent = 'Password is required';
    } else if (password.length < 6) {
        passwordError.textContent = 'Password must be at least 6 characters';
    } else {
        passwordError.textContent = '';
    }
});

// Check if already logged in
if (localStorage.getItem('isLoggedIn') === 'true') {
    window.location.href = 'dashboard.html';
}
