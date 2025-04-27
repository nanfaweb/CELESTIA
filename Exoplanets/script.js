document.addEventListener('DOMContentLoaded', () => {
    const planetListContainer = document.getElementById('planet-list'); // Target the UL
    const loader = document.getElementById('loader');
    const errorMessage = document.getElementById('error-message');

    // !! IMPORTANT !! Define your API endpoints
    const API_COUNT_URL = '/api/celestial-bodies/count'; // Endpoint for getting total count
    const API_DETAILS_URL = '/api/celestial-bodies';     // Endpoint for getting ALL bodies

    // Names to exclude (Our Solar System - Case Insensitive Check Recommended)
    const solarSystemExclusions = new Set([
        "sun", "mercury", "venus", "earth", "mars",
        "jupiter", "saturn", "uranus", "neptune",
         // Add more if needed
    ]);

    // --- Placeholder Data (Exoplanets) --- //
    const placeholderData = [
        { BodyID: 1, Name: "Kepler-186f", Type: "Planet", Mass: 1.4 * 5.972e+24, Diameter: 1.17 * 12742, Gravity: 11.0, OrbitalPeriod: 130, Description: "First Earth-sized planet discovered in the habitable zone of another star.", DiscoveredBy: "Kepler Space Telescope", DiscoveryDate: "2014-04-17" },
        { BodyID: 2, Name: "Gliese 581g", Type: "Planet", Mass: 3.1 * 5.972e+24, Diameter: 1.4 * 12742, Gravity: 15.0, OrbitalPeriod: 37, Description: "Potentially habitable exoplanet, existence debated.", DiscoveredBy: "W. M. Keck Observatory", DiscoveryDate: "2010-09-29" },
        { BodyID: 3, Name: "TRAPPIST-1e", Type: "Planet", Mass: 0.62 * 5.972e+24, Diameter: 0.91 * 12742, Gravity: 7.4, OrbitalPeriod: 6.1, Description: "Earth-sized exoplanet in the habitable zone of an ultra-cool dwarf star.", DiscoveredBy: "TRAPPIST", DiscoveryDate: "2017-02-22"},
        { BodyID: 4, Name: "Proxima Centauri b", Type: "Planet", Mass: 1.27 * 5.972e+24, Diameter: null, Gravity: null, OrbitalPeriod: 11.2, Description: "Closest known exoplanet to Earth, orbiting Proxima Centauri.", DiscoveredBy: "ESO (La Silla)", DiscoveryDate: "2016-08-24"},
        { BodyID: 5, Name: "HD 209458 b (Osiris)", Type: "Planet", Mass: 0.69 * 1.898e+27, Diameter: 1.38 * 139820, Gravity: 9.4 , OrbitalPeriod: 3.5, Description: "Hot Jupiter known for atmospheric studies.", DiscoveredBy: "Multiple Teams", DiscoveryDate: "1999-11-05"},
        { BodyID: 6, Name: "OGLE-2005-BLG-390Lb", Type: "Planet", Mass: 5.5 * 5.972e+24, Diameter: null, Gravity: null, OrbitalPeriod: 3500, Description: "One of the most distant and coldest exoplanets found via microlensing.", DiscoveredBy: "OGLE, PLANET Collab.", DiscoveryDate: "2006-01-25"}
    ];


    // Helper functions (formatNumber, formatDate) 
    function formatNumber(num, options = {}) { if (num === null || num === undefined) return "N/A"; const numVal = Number(num); if (isNaN(numVal)) return "N/A"; if (Math.abs(numVal) < 0.01 && numVal !== 0) { return numVal.toExponential(2); } if (Math.abs(numVal) > 1e6) { return numVal.toExponential(2); } const defaultOptions = { maximumFractionDigits: 2, ...options }; return numVal.toLocaleString(undefined, defaultOptions); }
    function formatDate(dateString) { if (!dateString) return "N/A"; try { return new Date(dateString).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' }); } catch (e) { return "Invalid Date"; } }

    // Display function (uses li)
    function displayPlanets(planets) {
        planetListContainer.innerHTML = '';
        errorMessage.style.display = 'none';

        if (!planets || planets.length === 0) {
            errorMessage.textContent = "No external celestial bodies found after filtering.";
            errorMessage.style.display = 'block';
            return;
        }

        planets.forEach(planet => {
            const listItem = document.createElement('li');
            listItem.className = 'planet-item';
            listItem.dataset.bodyId = planet.BodyID;

            // --- SVG MARKUP ---
            const svgIcon = `
                <div class="placeholder-svg-container">  
                    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                        <circle class="scan-ring ring1" cx="50" cy="50" r="45"/>
                        <circle class="scan-ring ring2" cx="50" cy="50" r="35"/>
                        <circle class="scan-ring ring3" cx="50" cy="50" r="25"/>
                    </svg>
                </div>
            `;

            // --- CARD innerHTML ---
            listItem.innerHTML = `
                <div class="planet-card-header" role="button" tabindex="0" aria-expanded="false" aria-controls="details-${planet.BodyID}">
                    ${svgIcon}  
                    <h2 class="planet-name">${planet.Name || 'Unknown Body'}</h2>
                </div>
                <div class="card-details" id="details-${planet.BodyID}">
                     <dl>
                         <div><dt>Type:</dt><dd>${planet.Type || 'N/A'}</dd></div>
                         <div><dt>Mass (kg):</dt><dd>${formatNumber(planet.Mass)}</dd></div>
                         <div><dt>Diameter (km):</dt><dd>${formatNumber(planet.Diameter, { maximumFractionDigits: 0 })}</dd></div>
                         <div><dt>Gravity (m/s²):</dt><dd>${formatNumber(planet.Gravity)}</dd></div>
                         <div><dt>Orbit (days):</dt><dd>${formatNumber(planet.OrbitalPeriod)}</dd></div>
                         <div><dt>Discovered:</dt><dd>${planet.DiscoveredBy || 'N/A'}</dd></div>
                         <div><dt>Date:</dt><dd>${formatDate(planet.DiscoveryDate)}</dd></div>
                         ${planet.Description ? `<div class="desc-block"><dt>Description:</dt><dd>${planet.Description}</dd></div>` : ''}
                     </dl>
                 </div>
            `;

            // Add listeners
            const header = listItem.querySelector('.planet-card-header');
            header.addEventListener('click', toggleDetails);
            header.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault(); toggleDetails(e);
                }
            });

            planetListContainer.appendChild(listItem);
        });
    }

    // Toggle function
    function toggleDetails(event) {
        const header = event.currentTarget;
        const listItem = header.closest('.planet-item');
        if (!listItem) return;
        const isExpanded = listItem.classList.toggle('expanded');
        header.setAttribute('aria-expanded', isExpanded);
         // Scroll the item somewhat into view when expanded (optional)
         if(isExpanded) {
            listItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
         }
    }

    // Error display (includes fallback)
    function displayError(message, context = "General Error") {
        loader.style.display = 'none';
        planetListContainer.innerHTML = '';
        errorMessage.textContent = `Data Error (${context}): ${message}`;
        errorMessage.style.display = 'block';
        console.warn(`${context}: Displaying placeholder planet data.`);
        displayPlanets(placeholderData); // Fallback to placeholder
    }

    // MAIN DATA FETCHING LOGIC
    async function initializeData() {
        loader.style.display = 'flex';
        errorMessage.style.display = 'none';
        planetListContainer.innerHTML = '';
        let totalCount = 0;

        try {
            const countResponse = await fetch(API_COUNT_URL);
            if (!countResponse.ok) throw new Error(`Count API Error: ${countResponse.status}`);
            const countData = await countResponse.json();
            totalCount = parseInt(countData.count, 10);
             if (isNaN(totalCount)) throw new Error("Invalid count format.");
            console.log(`Total bodies reported by backend: ${totalCount}`);
             if (totalCount <= 9 && totalCount !== 0) {
                 console.log("Count suggests <= 9 bodies total.");
             } else if (totalCount === 0) {
                 errorMessage.textContent = "Catalog is empty according to count.";
                 errorMessage.style.display = 'block';
                 loader.style.display = 'none';
                 return;
             }
        } catch (error) { console.error("Failed to fetch count:", error); displayError(error.message, "Count Fetch Failed"); }

        try {
            const detailsResponse = await fetch(API_DETAILS_URL);
            if (!detailsResponse.ok) throw new Error(`Details API Error: ${detailsResponse.status}`);
            const allBodies = await detailsResponse.json();
            if (!Array.isArray(allBodies)) throw new Error('Details API returned invalid format.');
            const filteredBodies = allBodies.filter(body => !solarSystemExclusions.has((body.Name || '').toLowerCase()));
            console.log(`Fetched ${allBodies.length} bodies, filtered to ${filteredBodies.length} exobodies.`);
            displayPlanets(filteredBodies);
        } catch (error) { console.error("Failed to fetch/process details:", error); displayError(error.message, "Details Fetch Failed"); }
        finally { loader.style.display = 'none'; }
    }

    // --- Initial Load ---
    initializeData();
});