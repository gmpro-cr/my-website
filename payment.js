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

// Go back to details page
function goBack() {
    window.location.href = 'details.html';
}

// Format currency
function formatCurrency(amount) {
    return '₹' + amount.toLocaleString('en-IN');
}

// Get selected card
function getSelectedCard() {
    const cardId = parseInt(localStorage.getItem('selectedCardId'));
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    return cards.find(card => card.id === cardId);
}

// Payment state
let paymentState = {
    selectedAmount: null,
    selectedUPI: null,
    card: null
};

// Load payment summary
function loadPaymentSummary() {
    const card = getSelectedCard();

    if (!card) {
        window.location.href = 'cards.html';
        return;
    }

    paymentState.card = card;

    const paymentSummary = document.getElementById('paymentSummary');
    paymentSummary.innerHTML = `
        <div class="summary-row">
            <span class="summary-label">Card</span>
            <span class="summary-value">${card.bank} ${card.cardNumber}</span>
        </div>
        <div class="summary-row">
            <span class="summary-label">Total Due</span>
            <span class="summary-value">${formatCurrency(card.totalDue)}</span>
        </div>
        <div class="summary-row">
            <span class="summary-label">Minimum Due</span>
            <span class="summary-value">${formatCurrency(card.minimumDue)}</span>
        </div>
    `;

    // Set amount values
    document.getElementById('minimumAmount').textContent = formatCurrency(card.minimumDue);
    document.getElementById('totalAmount').textContent = formatCurrency(card.totalDue);
}

// Select amount
function selectAmount(type) {
    const card = paymentState.card;
    const customSection = document.getElementById('customAmountSection');

    // Remove all previous selections
    document.querySelectorAll('.amount-btn').forEach(btn => {
        btn.classList.remove('selected');
    });

    // Add selection to clicked button
    event.target.closest('.amount-btn').classList.add('selected');

    if (type === 'minimum') {
        paymentState.selectedAmount = card.minimumDue;
        customSection.style.display = 'none';
    } else if (type === 'total') {
        paymentState.selectedAmount = card.totalDue;
        customSection.style.display = 'none';
    } else if (type === 'custom') {
        customSection.style.display = 'block';
        document.getElementById('customAmount').focus();
        paymentState.selectedAmount = null;
    }
}

// Handle custom amount input
document.addEventListener('DOMContentLoaded', function() {
    const customAmountInput = document.getElementById('customAmount');
    if (customAmountInput) {
        customAmountInput.addEventListener('input', function() {
            paymentState.selectedAmount = parseFloat(this.value) || null;
        });
    }
});

// Select UPI method
function selectUPI(method) {
    const upiIdSection = document.getElementById('upiIdSection');

    // Remove all previous selections
    document.querySelectorAll('.upi-method-btn').forEach(btn => {
        btn.classList.remove('selected');
    });

    // Add selection to clicked button
    event.target.closest('.upi-method-btn').classList.add('selected');

    paymentState.selectedUPI = method;

    if (method === 'upi') {
        upiIdSection.style.display = 'block';
        document.getElementById('upiId').focus();
    } else {
        upiIdSection.style.display = 'none';
    }
}

// Generate transaction ID
function generateTransactionId() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000000);
    return `TXN${timestamp}${random}`.substring(0, 16);
}

// Process payment
async function processPayment() {
    const card = paymentState.card;

    // Validate amount selection
    if (!paymentState.selectedAmount || paymentState.selectedAmount <= 0) {
        alert('Please select or enter a valid payment amount');
        return;
    }

    // Validate amount limits
    if (paymentState.selectedAmount > card.totalDue) {
        alert('Payment amount cannot exceed total due amount');
        return;
    }

    if (paymentState.selectedAmount < card.minimumDue && paymentState.selectedAmount !== card.totalDue) {
        const proceed = confirm(`The amount is less than minimum due (${formatCurrency(card.minimumDue)}). Do you want to proceed?`);
        if (!proceed) return;
    }

    // Validate UPI selection
    if (!paymentState.selectedUPI) {
        alert('Please select a UPI payment method');
        return;
    }

    // Validate UPI ID if selected
    if (paymentState.selectedUPI === 'upi') {
        const upiId = document.getElementById('upiId').value.trim();
        if (!upiId) {
            alert('Please enter your UPI ID');
            return;
        }
        // Basic UPI ID validation
        if (!upiId.includes('@')) {
            alert('Please enter a valid UPI ID');
            return;
        }
    }

    // Show loading
    const payBtn = document.querySelector('.action-section .btn-primary');
    const originalText = payBtn.textContent;
    payBtn.disabled = true;
    payBtn.innerHTML = '<span class="btn-loader"></span> Processing...';

    // Simulate payment processing
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Generate transaction ID
    const transactionId = generateTransactionId();

    // Update card data
    const cards = JSON.parse(localStorage.getItem('creditCards')) || [];
    const cardIndex = cards.findIndex(c => c.id === card.id);

    if (cardIndex !== -1) {
        cards[cardIndex].totalDue -= paymentState.selectedAmount;
        cards[cardIndex].availableCredit += paymentState.selectedAmount;

        // Update minimum due if total is less than it
        if (cards[cardIndex].totalDue < cards[cardIndex].minimumDue) {
            cards[cardIndex].minimumDue = cards[cardIndex].totalDue;
        }

        localStorage.setItem('creditCards', JSON.stringify(cards));
    }

    // Save payment history
    const paymentHistory = JSON.parse(localStorage.getItem('paymentHistory')) || [];
    paymentHistory.push({
        transactionId: transactionId,
        cardBank: card.bank,
        cardNumber: card.cardNumber,
        amount: paymentState.selectedAmount,
        upiMethod: getUPIName(paymentState.selectedUPI),
        date: new Date().toISOString(),
        status: 'success'
    });
    localStorage.setItem('paymentHistory', JSON.stringify(paymentHistory));

    // Reset button
    payBtn.disabled = false;
    payBtn.textContent = originalText;

    // Show success modal
    showSuccessModal(transactionId);
}

// Show success modal
function showSuccessModal(transactionId) {
    const modal = document.getElementById('successModal');
    const message = document.getElementById('successMessage');

    message.innerHTML = `
        <p style="margin-bottom: 16px;">Payment of <strong>${formatCurrency(paymentState.selectedAmount)}</strong> has been processed successfully via ${getUPIName(paymentState.selectedUPI)}.</p>
        <div style="background: var(--bg-gray-50); padding: 12px; border-radius: 8px; border: 1px solid var(--border-gray);">
            <div style="font-size: 12px; color: var(--text-tertiary); margin-bottom: 4px;">Transaction ID</div>
            <div style="font-family: 'Courier New', monospace; font-size: 14px; font-weight: 600; color: var(--text-primary);">${transactionId}</div>
        </div>
    `;

    modal.classList.add('show');
}

// Get UPI name
function getUPIName(method) {
    const names = {
        'gpay': 'Google Pay',
        'phonepe': 'PhonePe',
        'paytm': 'Paytm',
        'upi': 'UPI'
    };
    return names[method] || method;
}

// Return to cards page
function returnToCards() {
    window.location.href = 'dashboard.html';
}

// Initialize
checkAuth();
loadPaymentSummary();
