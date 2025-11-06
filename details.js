// Check authentication
function checkAuth() {
    if (localStorage.getItem('isLoggedIn') !== 'true') {
        window.location.href = 'index.html';
    }
}

// Logout function
function logout() {
    localStorage.removeItem('isLoggedIn');
    window.location.href = 'index.html';
}

// Go back to cards page
function goBack() {
    window.location.href = 'cards.html';
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

// Get selected card
function getSelectedCard() {
    const cardId = parseInt(localStorage.getItem('selectedCardId'));
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    return cards.find(card => card.id === cardId);
}

// Load card details
function loadCardDetails() {
    const card = getSelectedCard();

    if (!card) {
        window.location.href = 'cards.html';
        return;
    }

    // Load card header
    const cardHeader = document.getElementById('cardHeader');
    cardHeader.innerHTML = `
        <h1>${card.bank}</h1>
        <div class="card-detail-number">${card.cardNumber}</div>
        <div class="card-balance">
            <div class="balance-item">
                <div class="balance-label">Total Due</div>
                <div class="balance-amount">${formatCurrency(card.totalDue)}</div>
            </div>
            <div class="balance-item">
                <div class="balance-label">Minimum Due</div>
                <div class="balance-amount">${formatCurrency(card.minimumDue)}</div>
            </div>
        </div>
    `;

    // Load payment details
    const detailsGrid = document.getElementById('detailsGrid');
    detailsGrid.innerHTML = `
        <div class="detail-item">
            <div class="detail-label">Due Date</div>
            <div class="detail-value">${formatDate(card.dueDate)}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Credit Limit</div>
            <div class="detail-value">${formatCurrency(card.creditLimit)}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Available Credit</div>
            <div class="detail-value">${formatCurrency(card.availableCredit)}</div>
        </div>
        <div class="detail-item">
            <div class="detail-label">Used Credit</div>
            <div class="detail-value">${formatCurrency(card.creditLimit - card.availableCredit)}</div>
        </div>
    `;

    // Load transactions
    const transactionsList = document.getElementById('transactionsList');
    if (card.transactions && card.transactions.length > 0) {
        transactionsList.innerHTML = card.transactions.map(transaction => `
            <div class="transaction-item">
                <div class="transaction-info">
                    <div class="transaction-name">${transaction.name}</div>
                    <div class="transaction-date">${formatDate(transaction.date)}</div>
                </div>
                <div class="transaction-amount">${formatCurrency(transaction.amount)}</div>
            </div>
        `).join('');
    } else {
        transactionsList.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">No recent transactions</p>';
    }
}

// Proceed to payment
function proceedToPayment() {
    window.location.href = 'payment.html';
}

// Initialize
checkAuth();
loadCardDetails();
