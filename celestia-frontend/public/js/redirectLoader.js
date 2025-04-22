function redirectWithLoader(targetUrl) {
    localStorage.setItem('redirectTarget', targetUrl); // Store where to go
    window.location.href = '/loader.html'; // Go to loader
  }