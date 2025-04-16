// Wrap everything in an IIFE
(() => {
    // --- Configuration ---
    const DEFAULT_USERNAME = "Guest Explorer";
    const USERNAME_API_ENDPOINT = "/api/get-username"; // <-- CHANGE THIS

    // --- State Variables ---
    // REMOVED Three.js variables
    // REMOVED mouse, targetRotation

    // --- DOM Elements ---
    const sceneContainer = document.getElementById('scene-container'); // Keep if used for background parallax later
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

        // REMOVED initThreeJS() call
        // REMOVED animate() call

        // Add ready class immediately
        body.classList.add('app-ready');
        body.classList.add('cursor-ready');

        // REMOVED window resize listener for 3D

        console.log("Celestia: Initialization sequence complete.");
    }


    // --- Username Fetching ---
    async function fetchUsernameAndUpdateUI() {
        console.log("Celestia: Fetching username...");
        let finalUsername = DEFAULT_USERNAME;
        try {
            const response = await fetch(USERNAME_API_ENDPOINT);
            if (response.ok) {
                const data = await response.json();
                // IMPORTANT: Adjust 'data.username' based on your actual API response structure (Afnan do this shit)
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
            // Don't necessarily show error notification for failed username fetch unless desired
            // showNotification("Network Error", "Could not retrieve user data.", 5000);
        }
        if (usernameDisplay) {
             usernameDisplay.textContent = finalUsername;
              console.log(`Celestia: Username display updated to: ${finalUsername}`);
        }
        // Show welcome notification immediately after attempting fetch
        showNotification("System Online", `Welcome, ${finalUsername}.`, 4000);
    }

    // --- Custom Cursor ---
    function initCustomCursor() {
        console.log("Celestia: Initializing Custom Cursor...");
        if (!customCursor) return;
        const hoverables = document.querySelectorAll('a, button, #blackhole-loader');
        document.addEventListener('mousemove', (e) => {
            customCursor.style.left = `${e.clientX}px`; customCursor.style.top = `${e.clientY}px`;
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
        // Prevent re-triggering if particles are already generating
        if (!container || container.dataset.generating) return;
        container.dataset.generating = 'true'; // Set flag

        container.innerHTML = ''; // Clear previous before adding

        for (let i = 0; i < count; i++) {
            const particle = document.createElement("div");
            particle.classList.add("particle");

            // Randomize properties
            const size = Math.random() * 2.5 + 1; // Particle size (1px to 3.5px)
            const delay = Math.random() * 0.8; // Animation delay (0 to 0.8s)
            const duration = Math.random() * 1.0 + 1.2; // Animation duration (1.2s to 2.2s)
            const xStart = Math.random() * 80 + 10; // Horizontal start position (10% to 90%)
            const xEnd = (Math.random() - 0.5) * 30; // Horizontal end offset (-15px to +15px)

            // Apply styles via CSS variables and direct style
            particle.style.setProperty('--x-start', `${xStart}%`);
            particle.style.setProperty('--x-end', `${xEnd}px`);
            particle.style.width = `${size}px`;
            particle.style.height = `${size}px`;
            particle.style.left = `${xStart}%`; // Set initial left for positioning
            particle.style.animationDelay = `${delay}s`;
            particle.style.animationDuration = `${duration}s`;

            container.appendChild(particle);

            // Remove particle after animation completes to prevent buildup
            particle.addEventListener('animationend', () => {
                 particle.remove();
            });
        }

        // Allow re-triggering after a short delay
        setTimeout(() => {
            // Check if container still exists before deleting dataset property
             if (container) delete container.dataset.generating;
        }, 300); // Cooldown period in ms
    }


    // --- Notification System ---
    function initNotifications() {
         console.log("Celestia: Initializing Notifications...");
         if (!notificationContainer) {
              console.error("Celestia: Notification container not found!");
         }
     }

     function showNotification(title, message, duration = 4000) {
         if (!notificationContainer) return; // Don't proceed if container doesn't exist
         console.log(`Celestia: Showing notification - ${title}: ${message}`);

         // Create the notification element
         const notification = document.createElement("div");
         notification.classList.add("notification");

         // Set the inner HTML with title and message
         notification.innerHTML = `
             <div class="notification-title">${title}</div>
             <div class="notification-message">${message}</div>
         `;

         // Append to the container
         notificationContainer.appendChild(notification);

         // Force reflow before adding 'show' class to ensure transition works
         // requestAnimationFrame helps ensure the element is painted before the class change
         requestAnimationFrame(() => {
             notification.classList.add("show");
         });

         // Set a timeout to remove the notification
         setTimeout(() => {
             notification.classList.remove("show");
             // Wait for the transition to finish before removing from DOM
             notification.addEventListener('transitionend', () => {
                 // Check if the element still has a parent before removing
                 if (notification.parentNode) {
                      notification.remove();
                 }
             }, { once: true }); // Ensure listener is removed after firing once
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