import { initializeApp } from "firebase/app";
import { getAuth, applyActionCode, confirmPasswordReset, getRedirectResult } from "firebase/auth";
import { getFunctions, httpsCallable } from "firebase/functions";



async function getFirebaseConfig() {
    try {
        const functions = getFunctions(); // Initialize Functions before calling httpsCallable
        const getFirebaseConfigFn = httpsCallable(functions, 'getFirebaseConfig');
        const config = await getFirebaseConfigFn();
        return config.data;
    } catch (error) {
    console.error("Error getting Firebase config:", error);
    throw error; 
    }
}

  (async () => {  // Immediately Invoked Async Function Expression
    try {
      const config = await getFirebaseConfig();
      const app = initializeApp(config);
      const auth = getAuth(app);
      const functions = getFunctions(app); // Initialize Functions if you need it later for callable functions
      console.log("Firebase initialized successfully."); // Log success

    window.addEventListener('DOMContentLoaded', async () => {
        const mode = getParameterByName('mode');
        const oobCode = getParameterByName('oobCode');
        //const continueUrl = getParameterByName('continueUrl');

        function getParameterByName(name, url = window.location.href) {
            name = name.replace(/[\[\]]/g, '\\$&'); // Escape special characters in the parameter name
            const regex = new RegExp(`[?&]${name}(=([^&#]*)|&|#|$)`); // Create a regular expression to match the parameter
            const results = regex.exec(url); // Execute the regex against the URL
        
            if (!results) return null; // Return null if the parameter is not found
            if (!results[2]) return ''; // Return an empty string if the parameter has no value
        
            return decodeURIComponent(results[2].replace(/\+/g, ' ')); // Decode and return the parameter value
        }

    try {
        switch (mode) {
            case 'resetPassword': {
                const newPassword = prompt("Enter your new password:"); // Consider a more robust form for password input.
                if (!newPassword) {
                    document.getElementById('message').innerHTML = "<p>Password reset cancelled.</p>";
                    return;
                }

                await confirmPasswordReset(auth, oobCode, newPassword);
                document.getElementById('message').innerHTML = "<p>Password reset successful!</p>";

                break;  // Important: Add break statements to prevent fallthrough
            }
            case 'verifyEmail':
            case 'recoverEmail': {
                await applyActionCode(auth, oobCode);
                document.getElementById('message').innerHTML = `<p>Email ${mode === 'verifyEmail' ? 'verified' : 'recovered'} successfully!</p>`;

                break;
            }
            default:
                document.getElementById('message').innerHTML = "<p>Invalid action.</p>";
        }



        if (mode === 'resetPassword' || mode === 'verifyEmail' || mode === 'recoverEmail') {

            try {
                const callable = httpsCallable(functions, 'onEmailActionComplete');
                const result = await callable.call({ mode: mode, userId: auth.currentUser ? auth.currentUser.uid : null });
                console.log("Cloud function called successfully:", result.data);
                // Redirect if needed
                if (mode ==='verifyEmail'){
                    //if (continueUrl) window.location.href = continueUrl; // Redirect after successful verification or recovery - consider dynamic link usage
                    //else 
                    window.location.href = 'YOUR_REDIRECT_URL';
                }
            } catch (error) {
                console.error("Error calling Cloud Function:", error);
                document.getElementById('message').innerHTML = `<p>Error calling Cloud Function: ${error.message}</p>`


            }
        }

    } catch (error) {
            console.error("Error handling Firebase action:", error);
            document.getElementById('message').innerHTML = `<p>Error: ${error.message}</p>`;
    }


});

    } catch (error) {
        console.error("Firebase initialization failed:", error);
          // Handle initialization error (e.g., display an error message)

    }
})();

// function getParameterByName(name, url = window.location.href) {
//     name = name.replace(/[\[\]]/g, '\\$&'); // Escape special characters in the parameter name
//     const regex = new RegExp(`[?&]${name}(=([^&#]*)|&|#|$)`); // Create a regular expression to match the parameter
//     const results = regex.exec(url); // Execute the regex against the URL

//     if (!results) return null; // Return null if the parameter is not found
//     if (!results[2]) return ''; // Return an empty string if the parameter has no value

//     return decodeURIComponent(results[2].replace(/\+/g, ' ')); // Decode and return the parameter value
// }
