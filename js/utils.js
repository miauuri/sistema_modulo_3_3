const Utils = {
  formatCurrency: (amount) => {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
  },
  formatDate: (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric' });
  },
  validateEmail: (email) => {
    return String(email).toLowerCase().match(/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
  },
  showNotification: (message, type = 'success') => {
    // Implementación simple de toast
    const toast = document.createElement('div');
    toast.className = `fixed bottom-4 right-4 px-6 py-3 rounded-lg shadow-lg z-50 transition-all transform translate-y-0 opacity-100 ${
      type === 'success' ? 'bg-emerald-500 text-white' : 'bg-rose-500 text-white'
    }`;
    toast.textContent = message;
    document.body.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translate-y-2';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }
};