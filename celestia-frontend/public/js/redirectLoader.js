function redirectWithLoader(targetUrl) {
    localStorage.setItem('redirectTarget', targetUrl); // Store where to go
    window.location.href = '/loaderv2.html'; // Go to loader
  }