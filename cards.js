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

// Check if date is overdue
function isOverdue(dateString) {
    const dueDate = new Date(dateString);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return dueDate < today;
}

// Load and display cards
function loadCards() {
    const cardsGrid = document.getElementById('cardsGrid');
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];

    if (cards.length === 0) {
        cardsGrid.innerHTML = '<p style="text-align: center; color: var(--text-secondary);">No credit cards found.</p>';
        return;
    }

    cardsGrid.innerHTML = cards.map(card => `
        <div class="card-item" onclick="viewCard(${card.id})">
            <div class="card-bank">${card.bank}</div>
            <div class="card-number">${card.cardNumber}</div>
            <div class="card-info">
                <div>
                    <div class="card-label">Total Due</div>
                    <div class="card-amount ${isOverdue(card.dueDate) ? 'overdue' : ''}">${formatCurrency(card.totalDue)}</div>
                    <div class="card-due-date">Due: ${formatDate(card.dueDate)}</div>
                </div>
                <div style="text-align: right;">
                    <div class="card-label">Min. Due</div>
                    <div class="card-amount" style="font-size: 18px;">${formatCurrency(card.minimumDue)}</div>
                </div>
            </div>
        </div>
    `).join('');
}

// View card details
function viewCard(cardId) {
    localStorage.setItem('selectedCardId', cardId);
    window.location.href = 'details.html';
}

// Initialize
checkAuth();
loadCards();
