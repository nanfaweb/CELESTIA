function redirectWithLoader(targetUrl) {
    // Store both the target URL and its type
    sessionStorage.setItem("destinationAfterLoad", targetUrl);
    
    // Determine the correct loader path based on current location
    const currentPath = window.location.pathname;
    let loaderPath;
    
    if (currentPath.includes('/LandingPage/')) {
        // If we're in LandingPage, go up one level to public
        loaderPath = '../Loader/loader.html';
    } else {
        // Default path from root
        loaderPath = '/Loader/loader.html';
    }
    
    window.location.href = loaderPath;
}

// Wrap everything in an IIFE
(() => { 
    // Check if email is passed via query parameters (Google login)
    const urlParams = new URLSearchParams(window.location.search);
    const googleEmail = urlParams.get("email");
    const googleUserID = urlParams.get("userID"); // New: Check for userID

    if (googleEmail && googleUserID) {
        // Update session storage with the Google user's email and userID
        sessionStorage.setItem("userEmail", googleEmail);
        sessionStorage.setItem("userID", googleUserID); // New: Store userID
        console.log(`Google user logged in: ${googleEmail}, ID: ${googleUserID}`);

        // // Optionally, clear the query parameters from the URL
        // const newUrl = window.location.origin + window.location.pathname;
        // window.history.replaceState({}, document.title, newUrl);
    }

    const email = sessionStorage.getItem('userEmail');
    if (!email) {
        alert("You must login first!");
        window.location.href = "/login/index.html"; // Redirect back to login
    }

    // --- Configuration ---
    const DEFAULT_USERNAME = "Guest Explorer";
    const USERNAME_API_ENDPOINT = "http://localhost:3001/api/get-username";

    // --- DOM Elements ---
    const sceneContainer = document.getElementById('scene-container'); // For background parallax, etc.
    const usernameDisplay = document.getElementById('username-display');
    const optionsInterface = document.getElementById('options-interface');
    const closeBtn = document.getElementById('close-btn');
    const customCursor = document.getElementById('custom-cursor');
    const notificationContainer = document.getElementById('notification-container');
    const body = document.body;
    const blackholeLoader = document.getElementById('blackhole-loader'); // Get the new element

    // --- Initialization ---
    function init() {
        console.log("Celestia: DOM Ready. Starting initialization...");

        // Check for essential non-3D elements
        if (!blackholeLoader || !optionsInterface) {
            console.error("Celestia: Critical UI elements (blackhole loader or options interface) not found. Aborting.");
            alert("Initialization failed: Missing required UI elements.");
            return;
        }

        fetchUsernameAndUpdateUI();

        try { initCustomCursor(); } catch (e) { console.error("Celestia: Error initializing Custom Cursor:", e); }
        try { initUIInteractions(); } catch (e) { console.error("Celestia: Error initializing UI Interactions:", e); }
        try { initNotifications(); } catch (e) { console.error("Celestia: Error initializing Notifications:", e); }

        // Add ready class immediately
        body.classList.add('app-ready');
        body.classList.add('cursor-ready');

        console.log("Celestia: Initialization sequence complete.");
    }

    // --- Username Fetching ---
    async function fetchUsernameAndUpdateUI() {
        console.log("Celestia: Fetching username...");
        let finalUsername = DEFAULT_USERNAME;
        try {
            const response = await fetch(`${USERNAME_API_ENDPOINT}?email=${email}`);
            if (response.ok) {
                const data = await response.json();
                // IMPORTANT: Adjust 'data.username' based on your actual API response structure
                if (data && data.username) {
                    finalUsername = data.username;
                    console.log(`Celestia: Username fetched successfully: ${finalUsername}`);
                } else {
                    console.log("Celestia: Username endpoint OK, but no username found. Using default.");
                }
            } else {
                console.warn(`Celestia: Username endpoint status ${response.status}. Using default.`);
            }
        } catch (error) {
            console.error("Celestia: Error fetching username:", error);
        }
        if (usernameDisplay) {
            usernameDisplay.textContent = finalUsername;
            console.log(`Celestia: Username display updated to: ${finalUsername}`);
        }
        showNotification("System Online", `Welcome, ${finalUsername}.`, 4000);
    }

    // --- Custom Cursor ---
    function initCustomCursor() {
        console.log("Celestia: Initializing Custom Cursor...");
        if (!customCursor) return;
        const hoverables = document.querySelectorAll('a, button, #blackhole-loader');
        document.addEventListener('mousemove', (e) => {
            customCursor.style.left = `${e.clientX}px`; 
            customCursor.style.top = `${e.clientY}px`;
        });
        document.addEventListener('mousedown', () => customCursor.classList.add('clicking'));
        document.addEventListener('mouseup', () => customCursor.classList.remove('clicking'));
        hoverables.forEach(el => {
            el.addEventListener('mouseenter', () => customCursor.classList.add('active'));
            el.addEventListener('mouseleave', () => customCursor.classList.remove('active'));
        });
        customCursor.style.opacity = '1';
        document.addEventListener('mouseleave', () => customCursor.style.opacity = '0');
        document.addEventListener('mouseenter', () => customCursor.style.opacity = '1');
        console.log("Celestia: Custom Cursor Initialized.");
    }

    // --- UI Interactions Setup ---
    function initUIInteractions() {
        console.log("Celestia: Initializing UI Interactions...");

        if (blackholeLoader && optionsInterface) {
            blackholeLoader.addEventListener('click', () => {
                console.log("Celestia: Blackhole Clicked!");
                optionsInterface.classList.add('active');
                body.classList.remove('show-username');
            });
            console.log("Celestia: Blackhole click listener added.");
        } else {
            console.warn("Celestia: Blackhole or Options Interface not found for click listener.");
        }

        if (blackholeLoader && usernameDisplay) {
            blackholeLoader.addEventListener('mouseenter', () => {
                if (!optionsInterface?.classList.contains('active')) {
                    body.classList.add('show-username');
                }
            });
            blackholeLoader.addEventListener('mouseleave', () => {
                body.classList.remove('show-username');
            });
            console.log("Celestia: Blackhole hover listeners for username added.");
        }

        if (closeBtn && optionsInterface) {
            closeBtn.addEventListener('click', () => {
                optionsInterface.classList.remove('active');
            });
            console.log("Celestia: Close button listener added.");
        }

        if (optionsInterface) {
            optionsInterface.addEventListener('click', (e) => {
                if (e.target === optionsInterface) {
                    optionsInterface.classList.remove('active');
                }
            });
            console.log("Celestia: Options overlay click listener added.");
        }

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && optionsInterface?.classList.contains('active')) {
                closeBtn?.click();
            }
        });

        document.querySelectorAll('.option').forEach(option => {
            const particlesContainer = option.querySelector('.option-particles');
            const titleElement = option.querySelector('.option-title');
            option.addEventListener('click', (e) => {
                e.preventDefault();
                const title = titleElement?.textContent || 'Destination';
                showNotification("Navigation Engaged", `Plotting course for ${title}...`);
                const targetUrl = option.href;
                setTimeout(() => {
                    if (targetUrl && targetUrl !== '#' && !targetUrl.endsWith('#')) {
                        window.location.href = targetUrl;
                    } else {
                        console.warn("Celestia: Option link href is invalid:", targetUrl);
                        showNotification("Navigation Error", `Course plotting failed for ${title}.`, 5000);
                    }
                }, 600);
            });
            option.addEventListener('mouseenter', () => {
                if (particlesContainer) createOptionParticles(particlesContainer, 15);
            });
        });
        console.log("Celestia: Option listeners added.");
    }

    // --- Option Card Particles ---
    function createOptionParticles(container, count) {
        if (!container || container.dataset.generating) return;
        container.dataset.generating = 'true';
        container.innerHTML = '';
        for (let i = 0; i < count; i++) {
            const particle = document.createElement("div");
            particle.classList.add("particle");
            const size = Math.random() * 2.5 + 1;
            const delay = Math.random() * 0.8;
            const duration = Math.random() * 1.0 + 1.2;
            const xStart = Math.random() * 80 + 10;
            const xEnd = (Math.random() - 0.5) * 30;
            particle.style.setProperty('--x-start', `${xStart}%`);
            particle.style.setProperty('--x-end', `${xEnd}px`);
            particle.style.width = `${size}px`;
            particle.style.height = `${size}px`;
            particle.style.left = `${xStart}%`;
            particle.style.animationDelay = `${delay}s`;
            particle.style.animationDuration = `${duration}s`;
            container.appendChild(particle);
            particle.addEventListener('animationend', () => {
                particle.remove();
            });
        }
        setTimeout(() => {
            if (container) delete container.dataset.generating;
        }, 300);
    }

    // --- Notification System ---
    function initNotifications() {
        console.log("Celestia: Initializing Notifications...");
        if (!notificationContainer) {
            console.error("Celestia: Notification container not found!");
        }
    }

    function showNotification(title, message, duration = 4000) {
        if (!notificationContainer) return;
        console.log(`Celestia: Showing notification - ${title}: ${message}`);
        const notification = document.createElement("div");
        notification.classList.add("notification");
        notification.innerHTML = `
            <div class="notification-title">${title}</div>
            <div class="notification-message">${message}</div>
        `;
        notificationContainer.appendChild(notification);
        requestAnimationFrame(() => {
            notification.classList.add("show");
        });
        setTimeout(() => {
            notification.classList.remove("show");
            notification.addEventListener('transitionend', () => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, { once: true });
        }, duration);
    }

    // --- Start the Application ---
    if (document.readyState === 'loading') {
        console.log("Celestia: DOM not ready, waiting for DOMContentLoaded.");
        document.addEventListener('DOMContentLoaded', init);
    } else {
        console.log("Celestia: DOM already ready, calling init directly.");
        init();
    }

})(); // End of IIFE