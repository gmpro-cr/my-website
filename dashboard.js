// Check authentication
function checkAuth() {
    if (localStorage.getItem('isLoggedIn') !== 'true') {
        window.location.href = 'index.html';
    }
}

// Logout function
function logout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('loginTime');
        localStorage.removeItem('username');
        window.location.href = 'index.html';
    }
}

// Format currency
function formatCurrency(amount) {
    return '₹' + amount.toLocaleString('en-IN');
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-IN', options);
}

// Format date and time
function formatDateTime(dateString) {
    const date = new Date(dateString);
    const options = { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
    return date.toLocaleDateString('en-IN', options);
}

// Check if date is overdue
function isOverdue(dateString) {
    const dueDate = new Date(dateString);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return dueDate < today;
}

// Get days until due
function getDaysUntil(dateString) {
    const dueDate = new Date(dateString);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    dueDate.setHours(0, 0, 0, 0);
    const diffTime = dueDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
}

// Load user name
function loadUserName() {
    const username = localStorage.getItem('username') || 'User';
    document.getElementById('userName').textContent = username.charAt(0).toUpperCase() + username.slice(1);
}

// Load payment reminders
function loadPaymentReminders() {
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    const remindersContainer = document.getElementById('paymentReminders');

    const overdueCards = cards.filter(card => isOverdue(card.dueDate) && card.totalDue > 0);
    const upcomingCards = cards.filter(card => {
        const days = getDaysUntil(card.dueDate);
        return days >= 0 && days <= 7 && card.totalDue > 0;
    });

    let html = '';

    if (overdueCards.length > 0) {
        html += '<div class="reminder-card reminder-danger">';
        html += '<div class="reminder-icon">⚠️</div>';
        html += '<div class="reminder-content">';
        html += '<h3>Overdue Payments</h3>';
        html += `<p>You have ${overdueCards.length} credit card(s) with overdue payments. Please pay immediately to avoid penalties.</p>`;
        html += '<ul class="reminder-list">';
        overdueCards.forEach(card => {
            html += `<li><strong>${card.bank}</strong> - ${formatCurrency(card.minimumDue)} minimum due</li>`;
        });
        html += '</ul>';
        html += '</div></div>';
    }

    if (upcomingCards.length > 0) {
        html += '<div class="reminder-card reminder-warning">';
        html += '<div class="reminder-icon">📅</div>';
        html += '<div class="reminder-content">';
        html += '<h3>Upcoming Payments</h3>';
        html += `<p>You have ${upcomingCards.length} payment(s) due in the next 7 days.</p>`;
        html += '<ul class="reminder-list">';
        upcomingCards.forEach(card => {
            const days = getDaysUntil(card.dueDate);
            html += `<li><strong>${card.bank}</strong> - Due in ${days} day(s) - ${formatCurrency(card.minimumDue)}</li>`;
        });
        html += '</ul>';
        html += '</div></div>';
    }

    remindersContainer.innerHTML = html;
}

// Load quick stats
function loadQuickStats() {
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    const paymentHistory = JSON.parse(localStorage.getItem('paymentHistory')) || [];

    // Total due
    const totalDue = cards.reduce((sum, card) => sum + card.totalDue, 0);
    document.getElementById('totalDue').textContent = formatCurrency(totalDue);

    // Active cards
    document.getElementById('activeCards').textContent = cards.length;

    // Upcoming payments (due in next 30 days)
    const upcomingCount = cards.filter(card => {
        const days = getDaysUntil(card.dueDate);
        return days >= 0 && days <= 30 && card.totalDue > 0;
    }).length;
    document.getElementById('upcomingPayments').textContent = upcomingCount;

    // Paid this month
    const thisMonth = new Date().getMonth();
    const thisYear = new Date().getFullYear();
    const paidThisMonth = paymentHistory
        .filter(payment => {
            const paymentDate = new Date(payment.date);
            return paymentDate.getMonth() === thisMonth && paymentDate.getFullYear() === thisYear;
        })
        .reduce((sum, payment) => sum + payment.amount, 0);
    document.getElementById('paidThisMonth').textContent = formatCurrency(paidThisMonth);
}

// Load credit cards
function loadCards() {
    const cardsGrid = document.getElementById('cardsGrid');
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];

    if (cards.length === 0) {
        cardsGrid.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">No credit cards found.</p>';
        return;
    }

    cardsGrid.innerHTML = cards.map(card => `
        <div class="dashboard-card-item">
            <div class="card-header-section">
                <div class="card-bank">${card.bank}</div>
                <div class="card-number">${card.cardNumber}</div>
            </div>

            <div class="card-stats">
                <div class="card-stat">
                    <span class="card-label">Total Due</span>
                    <span class="card-amount ${isOverdue(card.dueDate) && card.totalDue > 0 ? 'overdue' : ''}">${formatCurrency(card.totalDue)}</span>
                </div>
                <div class="card-stat">
                    <span class="card-label">Due Date</span>
                    <span class="card-due ${isOverdue(card.dueDate) && card.totalDue > 0 ? 'overdue' : ''}">${formatDate(card.dueDate)}</span>
                </div>
            </div>

            <div class="card-actions">
                <button class="btn btn-small btn-secondary" onclick="viewCard(${card.id})">View Details</button>
                <button class="btn btn-small btn-primary" onclick="quickPay(${card.id})" ${card.totalDue === 0 ? 'disabled' : ''}>Quick Pay</button>
            </div>
        </div>
    `).join('');
}

// View card details
function viewCard(cardId) {
    localStorage.setItem('selectedCardId', cardId);
    window.location.href = 'details.html';
}

// Quick pay
function quickPay(cardId) {
    localStorage.setItem('selectedCardId', cardId);
    window.location.href = 'payment.html';
}

// Load recent transactions
function loadRecentTransactions() {
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    const transactionsContainer = document.getElementById('recentTransactions');

    // Collect all transactions from all cards
    const allTransactions = [];
    cards.forEach(card => {
        if (card.transactions) {
            card.transactions.forEach(transaction => {
                allTransactions.push({
                    ...transaction,
                    cardBank: card.bank
                });
            });
        }
    });

    // Sort by date (most recent first)
    allTransactions.sort((a, b) => new Date(b.date) - new Date(a.date));

    // Show only 5 most recent
    const recentTransactions = allTransactions.slice(0, 5);

    if (recentTransactions.length === 0) {
        transactionsContainer.innerHTML = '<p style="text-align: center; color: var(--text-secondary); padding: 20px;">No recent transactions</p>';
        return;
    }

    transactionsContainer.innerHTML = recentTransactions.map(transaction => `
        <div class="transaction-item">
            <div class="transaction-icon">🛒</div>
            <div class="transaction-info">
                <div class="transaction-name">${transaction.name}</div>
                <div class="transaction-meta">
                    <span class="transaction-card">${transaction.cardBank}</span>
                    <span class="transaction-date">${formatDate(transaction.date)}</span>
                </div>
            </div>
            <div class="transaction-amount">-${formatCurrency(transaction.amount)}</div>
        </div>
    `).join('');
}

// Show all transactions
function showAllTransactions() {
    // Navigate to first card's details page
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    if (cards.length > 0) {
        viewCard(cards[0].id);
    }
}

// Load payment history
function loadPaymentHistory() {
    const paymentHistory = JSON.parse(localStorage.getItem('paymentHistory')) || [];
    const historyContainer = document.getElementById('paymentHistoryList');

    if (paymentHistory.length === 0) {
        historyContainer.innerHTML = '<p style="text-align: center; color: var(--text-secondary); padding: 20px;">No payment history yet. Make your first payment!</p>';
        return;
    }

    // Sort by date (most recent first)
    paymentHistory.sort((a, b) => new Date(b.date) - new Date(a.date));

    historyContainer.innerHTML = paymentHistory.map(payment => `
        <div class="payment-history-item">
            <div class="payment-history-icon">✓</div>
            <div class="payment-history-info">
                <div class="payment-history-title">Payment to ${payment.cardBank}</div>
                <div class="payment-history-meta">
                    <span>${formatDateTime(payment.date)}</span>
                    <span>•</span>
                    <span>via ${payment.upiMethod}</span>
                    <span>•</span>
                    <span>Txn ID: ${payment.transactionId}</span>
                </div>
            </div>
            <div class="payment-history-amount">-${formatCurrency(payment.amount)}</div>
        </div>
    `).join('');
}

// Dark mode toggle
function toggleDarkMode() {
    const body = document.body;
    const themeIcon = document.getElementById('themeIcon');

    body.classList.toggle('dark-mode');

    if (body.classList.contains('dark-mode')) {
        themeIcon.textContent = '☀️';
        localStorage.setItem('darkMode', 'true');
    } else {
        themeIcon.textContent = '🌙';
        localStorage.setItem('darkMode', 'false');
    }
}

// Load dark mode preference
function loadDarkMode() {
    const isDarkMode = localStorage.getItem('darkMode') === 'true';
    if (isDarkMode) {
        document.body.classList.add('dark-mode');
        document.getElementById('themeIcon').textContent = '☀️';
    }
}

// Show help modal
function showHelp() {
    document.getElementById('helpModal').classList.add('show');
}

// Close help modal
function closeHelp() {
    document.getElementById('helpModal').classList.remove('show');
}

// Close modal on outside click
window.addEventListener('click', function(event) {
    const helpModal = document.getElementById('helpModal');
    if (event.target === helpModal) {
        closeHelp();
    }
});

// Initialize
checkAuth();
loadUserName();
loadPaymentReminders();
loadQuickStats();
loadCards();
loadRecentTransactions();
loadPaymentHistory();
loadDarkMode();
