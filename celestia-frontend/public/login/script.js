document.addEventListener('DOMContentLoaded', () => {
    const authForm = document.getElementById('auth-form');
    const tabLinks = document.querySelectorAll('.tab-link');
    const messageArea = document.getElementById('message-area');
    const submitButton = document.getElementById('submit-button');
    const btnText = submitButton.querySelector('.btn-text');
    const btnLoader = submitButton.querySelector('.btn-loader');

    // Input Groups & Fields
    const usernameGroup = document.getElementById('username-group');
    const confirmPasswordGroup = document.getElementById('confirm-password-group');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password'); // Get password field
    const usernameInput = document.getElementById('username');
    const confirmPasswordInput = document.getElementById('confirm-password'); // Get confirm field

    // Background elements for parallax
    const stars1 = document.getElementById('stars1');
    const stars2 = document.getElementById('stars2');
    const stars3 = document.getElementById('stars3');
    const nebula = document.getElementById('nebula');
    const planets = document.querySelectorAll('.planet');

    // !! IMPORTANT !! - Update these URLs
    const SIGNUP_API_URL = 'http://localhost:3001/api/users'; 
    const LOGIN_API_URL = 'http://localhost:3001/api/users/login';

    let currentMode = 'signup'; // 'signup' or 'login'

    // --- Parallax Effect ---
    const MAX_OFFSET = 20; // Max pixels the background moves

    // Google OAuth
    function handleGoogleSignIn() {
        window.location.href = "http://localhost:3001/api/auth/google";
    }

    document.getElementById('google-signin-btn').addEventListener('click', handleGoogleSignIn);

    // Handle Google OAuth callback
    async function handleGoogleOAuthCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const email = urlParams.get('email');
        const userID = urlParams.get('userID'); // New

        if (email && userID) {
            // Store the authenticated user's email and userID in sessionStorage
            sessionStorage.setItem('userEmail', email);
            sessionStorage.setItem('userID', userID);
            window.location.href = "/LandingPage/index.html";
        } else {
            console.error("Google OAuth callback failed: Missing email or userID.");
            alert("Google Sign-In failed. Please try again.");
        }
    }

    // Check if the current page is the OAuth callback page
    if (window.location.pathname.includes("google/callback")) {
        handleGoogleOAuthCallback();
    }

    function handleMouseMove(e) {
        const percX = (e.clientX / window.innerWidth - 0.5) * 2; // -1 to 1
        const percY = (e.clientY / window.innerHeight - 0.5) * 2; // -1 to 1

        const offsetX = percX * MAX_OFFSET;
        const offsetY = percY * MAX_OFFSET;

        // Apply parallax with different strengths (data-depth can be used if elements added dynamically)
        stars1.style.transform = `translate(${offsetX * 0.2}px, ${offsetY * 0.2}px)`;
        stars2.style.transform = `translate(${offsetX * 0.4}px, ${offsetY * 0.4}px)`;
        stars3.style.transform = `translate(${offsetX * 0.6}px, ${offsetY * 0.6}px)`;
        nebula.style.transform = `translate(${offsetX * 0.3}px, ${offsetY * 0.3}px) scale(1.1)`; // slight scale for depth

        planets.forEach(planet => {
            const depth = parseFloat(planet.dataset.depth || 0.5); // Use data-depth or default
            planet.style.transform = `translate(${offsetX * depth * 1.5}px, ${offsetY * depth * 1.5}px)`;
        });
    }
    // Add listener only if not on a touch device (optional optimization)
    if (!('ontouchstart' in window)) {
        document.body.addEventListener('mousemove', handleMouseMove);
    }


    // --- Tab Switching ---
    tabLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const newMode = link.dataset.tab;
            if (newMode === currentMode) return;

            currentMode = newMode;

            tabLinks.forEach(l => l.classList.remove('active'));
            link.classList.add('active');

            // Smoothly hide/show fields
            if (currentMode === 'signup') {
                usernameGroup.classList.remove('hidden');
                confirmPasswordGroup.classList.remove('hidden');
                btnText.textContent = 'Initiate Sequence';
                usernameInput.required = true;
                confirmPasswordInput.required = true;
            } else { // login
                usernameGroup.classList.add('hidden');
                confirmPasswordGroup.classList.add('hidden');
                btnText.textContent = 'Engage'; // Shorter login text
                usernameInput.required = false;
                confirmPasswordInput.required = false;
            }
            clearMessages();
            // authForm.reset(); // Optional: Reset form on switch
        });
    });


    // --- Display Messages ---
    function displayMessage(message, isError = false) {
        messageArea.textContent = message;
        messageArea.className = 'message-area'; // Reset classes
        if (message) {
            messageArea.classList.add(isError ? 'error' : 'success');
        } else {
           // Ensure it's hidden if message is empty
            messageArea.style.display = 'none';
        }
    }

    function clearMessages() {
        messageArea.textContent = '';
        messageArea.className = 'message-area';
        messageArea.style.display = 'none';
    }

    // --- Form Submission Handling ---
    authForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        clearMessages();
        const email = emailInput.value;
        const password = passwordInput.value;
  
        try {
            const response = await fetch('/api/users/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
      
            const result = await response.json();
            if (result.success) {
                // Store the authenticated user ID & email in sessionStorage for ephemeral session data
                sessionStorage.setItem('userID', result.userID);
                sessionStorage.setItem('userEmail', email);
                window.location.href = "/LandingPage/index.html";
            } else {
                displayMessage(result.message, true);
            }
        } catch (error) {
            displayMessage("Login failed. Please try again.", true);
            console.error("Error during login:", error);
        }
    });

    // --- Initial State ---
    // Ensure fields match the default mode ('signup')
    usernameGroup.classList.remove('hidden');
    confirmPasswordGroup.classList.remove('hidden');
    usernameInput.required = true;
    confirmPasswordInput.required = true;

    // Initial message clear
    clearMessages();
});