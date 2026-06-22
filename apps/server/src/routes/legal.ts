import { Hono } from "hono";
import { html } from "hono/html";

export const legal = new Hono();

const privacyPolicyHTML = html`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Privacy Policy - JustHookUps</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", sans-serif;
      line-height: 1.6;
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
      color: #333;
    }
    h1 { color: #000; margin-top: 30px; }
    h2 { color: #222; margin-top: 25px; }
    a { color: #0066cc; }
    .last-updated { color: #666; font-style: italic; margin-bottom: 30px; }
  </style>
</head>
<body>
  <h1>Privacy Policy</h1>
  <p class="last-updated">Effective Date: June 21, 2026</p>

  <p><strong>App Name:</strong> JustHookUps — Casual Dating App</p>
  <p><strong>Developer:</strong> NeoNebula</p>

  <p>By using our Service you understand and agree that we are providing a platform for you to post content, including photos, comments and other materials ("User Content"), to the Service and to share User Content publicly. This means that other Users may search for, see, use, or share any of your User Content that you make publicly available through the Service, consistent with the terms and conditions of this Privacy Policy and our Terms of Use.</p>

  <p>This Privacy Policy explains how information is collected, used and disclosed by Our Team with respect to your access and use of our services through our mobile applications and website. This Privacy Policy doesn't apply to any third-party websites, services or applications that can be accessed through our services.</p>

  <h2>1. Information you provide us directly</h2>
  <p>We will collect personal information from you (like username, email address, date of birth, gps location, city, country, photo and gender) when you create an account. You also provide the following information:</p>

  <h3>a. Your Messages</h3>
  <p>We will store the contents of your posts, messages, both sent and received, and any files (such as photos) attached to those messages so that you may access them at any time from any authenticated device.</p>

  <h3>b. Note regarding children</h3>
  <p>We do not knowingly collect personal information from children. If we learn that we have collected personal information of a child under 18, we will take steps to delete such information from our files as soon as possible.</p>

  <h3>c. Note regarding international users</h3>
  <p>Your information may be transferred to, processed, and maintained on globally distributed cloud infrastructure through our hosting providers, ensuring optimization and performance based on your structural proximity. By providing us with your information, you are accepting and agreeing to that transfer and processing.</p>

  <p>When you complete your profile, you can share with us additional information, such as details on your personality, lifestyle, interests and other details about you, as well as content such as photos and videos. To add certain content, like pictures or videos, you may allow us to access your camera or photo album. Some of the information you choose to provide us may be considered "special" or "sensitive" in certain jurisdictions, for example your racial or ethnic origins, sexual orientation and religious beliefs. By choosing to provide this information, you consent to our processing of that information.</p>

  <h2>2. Information We Collect</h2>

  <h3>a. Your Device/Computer</h3>
  <p>We collect certain information that your mobile device sends when you use our services, like a device identifier, user settings, and the operating system, as well as information about your use of our services through your device. We also collect certain information that your web browser sends when you visit our website, like the IP address, browser, referring/exit pages and URLs, pages viewed, and other such information about your use of our services.</p>

  <h3>b. Cookies</h3>
  <p>We use "cookies" – small data files – to collect this information, which allows us to identify your browser and to improve your use of our services when you access our website. You can reset your web browser to refuse all cookies or to indicate when a cookie is being sent, however, some features of our services may not function properly if the ability to accept cookies is disabled.</p>

  <h3>c. Metadata</h3>
  <p>Metadata is usually technical data that is associated with User Content. For example, Metadata can describe how, when and by whom a piece of User Content was collected and how that content is formatted. Users can add or may have Metadata added to their User Content including a hashtag (e.g., to mark keywords when you post a photo), geotag (e.g., to mark your location to a photo), comments or other data. This makes your User Content more searchable by others and more interactive.</p>

  <h2>3. Information Collected by Others</h2>
  <p>We may use analytics providers to help us understand the use of our services. These providers will collect the information sent by your mobile device or browser, and their use of that information is governed by their applicable privacy policy.</p>

  <h3>a. Other Users</h3>
  <p>Other users may provide information about you as they use our services. For instance, we may collect information about you from other users if they contact us about you.</p>

  <h3>b. Social Media</h3>
  <p>You may be able to use your social media login (such as Facebook Login) to create and log into your JustHookUps account. This saves you from having to remember yet another user name and password. We only need the user id at the social media.</p>

  <h3>c. Other Partners</h3>
  <p>We may receive info about you from our partners, for instance where JustHookUps ads are published on a partner's websites and platforms (in which case they may pass along details on a campaign's success).</p>

  <h2>4. Information collected when you use our services</h2>
  <p>When you use our services, we collect information about which features you've used, how you've used them and the devices you use to access our services. See below for more details:</p>

  <h3>a. Usage Information</h3>
  <p>We collect information about your activity on our services, for instance how you use them (e.g., date and time you logged in, features you've been using, searches, clicks and pages which have been shown to you, referring webpage address, advertising that you click on) and how you interact with other users (e.g., users you connect and interact with, time and date of your exchanges, number of messages you send and receive).</p>

  <h3>b. Device information</h3>
  <p>We collect information from and about the device(s) you use to access our services, including: hardware and software information such as IP address, device ID and type, device-specific and apps settings and characteristics, app crashes, advertising IDs (such as Google's AAID and Apple's IDFA, both of which are randomly generated numbers that you can reset by going into your device' settings), browser type, version and language, operating system, time zones, identifiers associated with cookies or other technologies that may uniquely identify your device or browser (e.g., IMEI/UDID and MAC address).</p>

  <h3>c. Other information with your consent</h3>
  <p>If you give us permission, we can collect your precise geolocation (latitude and longitude) through various means, depending on the service and device you're using, including GPS, Bluetooth or Wi-Fi connections. The collection of your geolocation may occur in the background even when you aren't using the services if the permission you gave us expressly permits such collection. If you decline permission for us to collect your geolocation, we will not collect it. Similarly, if you consent, we may collect your photos and videos (for instance, if you want to publish a photo, video or streaming on the services).</p>

  <h2>5. How We Use the Information We Collect</h2>
  <p>We use the information we collect to provide our services, to respond to inquiries, to personalize and improve our services and your experiences when you use our services, to monitor and analyze usage and trends of our services, to send you administrative messages regarding the operation and use of our services, and for any other purpose for which the information was collected.</p>

  <h3>To administer your account and provide our services to you</h3>
  <ul>
    <li>Create and manage your account</li>
    <li>Provide you with customer support and respond to your requests</li>
    <li>Complete your transactions</li>
    <li>Communicate with you about our services, including order management and billing</li>
  </ul>

  <h3>To help you connect with other users</h3>
  <ul>
    <li>Analyze your profile, activity on the service, and preferences to recommend meaningful connections to you and recommend you to others</li>
    <li>Show users' profiles to one another</li>
  </ul>

  <h3>To ensure a consistent experience across your devices</h3>
  <p>Link the various devices you use so that you can enjoy a consistent experience of our services on all of them. We do this by linking devices and browser data, such as when you log into your account on different devices or by using partial or full IP address, browser version and similar data about your devices to help identify and link them.</p>

  <h3>To provide new services to you</h3>
  <ul>
    <li>Register you and display your profile on new features and apps</li>
    <li>Administer your account on these new features and apps</li>
  </ul>

  <h3>To serve you relevant offers and ads</h3>
  <ul>
    <li>Administer sweepstakes, contests, discounts or other offers</li>
    <li>Develop, display and track content and advertising tailored to your interests on our services and other sites</li>
    <li>Communicate with you by email, phone, social media or mobile device about products or services that we think may interest you</li>
  </ul>

  <h3>To improve our services and develop new ones</h3>
  <ul>
    <li>Administer focus groups and surveys</li>
    <li>Conduct research and analysis of users' behavior to improve our services and content</li>
    <li>Develop new features and services</li>
  </ul>

  <h3>To prevent, detect and fight fraud or other illegal or unauthorized activities</h3>
  <ul>
    <li>Address ongoing or alleged misbehavior on and off-platform</li>
    <li>Perform data analysis to better understand and design countermeasures against these activities</li>
    <li>Retain data related to fraudulent activities to prevent against recurrences</li>
  </ul>

  <h3>To ensure legal compliance</h3>
  <ul>
    <li>Comply with legal requirements</li>
    <li>Assist law enforcement</li>
    <li>Enforce or exercise our rights, for example our Terms</li>
  </ul>

  <h2>6. Legal Bases for Processing</h2>
  <p>To process your information as described above, we rely on the following legal bases:</p>

  <h3>Provide our service to you</h3>
  <p>Most of the time, the reason we process your information is to perform the contract that you have with us. For instance, as you go about using our service to build meaningful connections, we use your information to maintain your account and your profile, to make it viewable to other users and recommend other users to you.</p>

  <h3>Legitimate interests</h3>
  <p>We may use your information where we have legitimate interests to do so. For instance, we analyze users' behavior on our services to continuously improve our offerings, we suggest offers we think might interest you, and we process information for administrative, fraud detection and other legal purposes.</p>

  <h3>Consent</h3>
  <p>From time to time, we may ask for your consent to use your information for certain specific reasons. You may withdraw your consent at any time by contacting us at the address provided at the end of this Privacy Policy.</p>

  <h2>7. How Long We Retain Your Information</h2>
  <p>We will delete your account immediately when you request. You can click the "Delete Account" button at app settings or you can send an email to our support email address.</p>
  <p>The information must be kept for our legitimate business interests, such as fraud prevention and enhancing users' safety and security. For example, information may need to be kept to prevent a user who was banned for unsafe behavior or security incidents from opening a new account.</p>

  <h2>8. Information We Share With Others</h2>
  <p>We will share information about you when you instruct us to do so, or if we notify you that the information you provide will be shared in a particular manner and you provide such information.</p>
  <p>We may share information about you in anonymous and/or aggregated form with third parties for usage analytics, industry analysis, demographic profiling, research, and other similar purposes.</p>
  <p>Your information may be accessed and used by our service providers who are working with us in connection with the operation of our services (these service providers have access to your information only to the extent necessary to perform services on our behalf and are obligated not to disclose or use it for any other purposes).</p>
  <p>We may share information about you if we are (or if we believe we are) required by law or legal process, if we have to respond to a lawful request from legal authorities to disclose such information, or if we need to enforce or apply this Privacy Policy, our Terms or our other policies.</p>
  <p>We may transfer and/or provide information about our users in connection with an acquisition, sale of company assets, or other situation where user information would be transferred as one of our business assets.</p>

  <h2>9. How to Access Your Information</h2>
  <p>Following termination or deactivation of your account, our system may retain information (including your profile information) and User Content for a commercially reasonable time for backup, archival, and/or audit purposes. Once your account is deleted, you will no longer have access to your message history, preferences or any other information associated with your use of our services. Even after you remove information from your account or profile, copies of that information may remain viewable elsewhere, to the extent it has been shared with others, it was otherwise distributed pursuant to your privacy settings, or it was copied or stored by other users.</p>

  <h2>10. Other Web Sites and Services</h2>
  <p>We are not responsible for the practices employed by any websites or services linked to or from our Service, including the information or content contained within them. Please remember that when you use a link to go from our Service to another website or service, our Privacy Policy does not apply to those third-party websites or services. Your browsing and interaction on any third-party website or service, including those that have a link on our website, are subject to that third party's own rules and policies. In addition, you agree that we are not responsible and do not have control over any third-parties that you authorize to access your User Content.</p>

  <h2>11. Security Measures We Take To Protect Your Information</h2>
  <p>We employ administrative, physical and electronic measures designed to protect your information from unauthorized access, however, despite these efforts, no security measures are perfect or impenetrable and no method of data transmission can be guaranteed against any interception or other type of misuse. In the event that your personal information is compromised as a result of a breach of security, we will promptly notify you if your personal information has been compromised, as required by applicable law.</p>

  <h2>12. Information Security Framework</h2>
  <ul>
    <li>We test our app and systems for vulnerabilities and security issues at least every 12 months.</li>
    <li>All sensitive data is encrypted stored, like credentials and access tokens.</li>
    <li>We test our incident response systems and processes at least every 12 months.</li>
    <li>We have a system for maintaining accounts (assigning, revoking, reviewing access and privileges).</li>
    <li>We have a system for keeping system code and environments updated, including servers, virtual machines, distributions, libraries, packages, and security configurations.</li>
    <li>We have a system in place for logging access to Platform Data and tracing where Platform Data was sent and stored.</li>
    <li>We monitor transfers of Platform Data and key points where Platform Data can leave the system (e.g., third parties, public endpoints).</li>
    <li>We have an automated system for monitoring logs and other security events, and to generate alerts for abnormal or security-related events.</li>
  </ul>

  <h2>13. Changes to our Privacy Policy</h2>
  <p>We may modify or update this Privacy Policy from time to time, so please review it periodically. Any information that is collected is subject to the Privacy Policy in effect at the time such information is collected. If we make any material changes to this policy, we will notify you of such changes by posting them on our website, through our services or by sending you an email or other notification, and we will indicate when such changes will become effective. By continuing to access or use our services after those changes become effective, you are agreeing to be bound by the revised policy.</p>

  <h2>14. Facebook Login and Other Social Media Login</h2>
  <p>We use the Facebook Login SDK. You can use this login method to register a new account in our app. We only need the user id and token returned by the SDK. We don't use or store your public profile details, like your full name, email address, or photo from Facebook directly unless explicitly provided. We use the user id to make a new account associated with your Facebook credentials. You will use this new account to access our app and use the services we provide. All information associated will be deleted when you click the "Delete Account" button in app settings. All user information like username, photo, gender, age will be completely removed. The Facebook user id we used will be removed also. You can also request to delete your account by sending an email to our support email.</p>

  <h2>15. Contacting Us</h2>
  <p>If you have any questions about our Privacy Policy, please contact us at:</p>
  <p><strong>Email:</strong> <a href="mailto:thabang.soulo@neonebula.co.za">thabang.soulo@neonebula.co.za</a></p>

  <hr style="margin-top: 40px; margin-bottom: 20px; border: none; border-top: 1px solid #ddd;">
  <p style="font-size: 12px; color: #999;">Last updated: June 21, 2026</p>
</body>
</html>
`;

legal.get("/privacy-policy", (c) => {
	return c.html(privacyPolicyHTML);
});

legal.get("/privacy-policy/json", (c) => {
	return c.json({
		title: "Privacy Policy",
		app: "JustHookUps",
		developer: "NeoNebula",
		effectiveDate: "2026-06-21",
		url: `${new URL(c.req.url).origin}/privacy-policy`,
	});
});

const accountDeletionHTML = html`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Request Account Deletion - CasualMeets</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .container {
      background: white;
      border-radius: 12px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      max-width: 500px;
      width: 100%;
      padding: 40px;
    }
    h1 {
      color: #1a1a1a;
      margin-bottom: 8px;
      font-size: 28px;
    }
    .subtitle {
      color: #666;
      margin-bottom: 30px;
      font-size: 14px;
      line-height: 1.5;
    }
    .form-group {
      margin-bottom: 24px;
    }
    label {
      display: block;
      color: #333;
      font-weight: 500;
      margin-bottom: 8px;
      font-size: 14px;
    }
    input {
      width: 100%;
      padding: 12px;
      border: 1px solid #ddd;
      border-radius: 8px;
      font-size: 14px;
      font-family: inherit;
      transition: border-color 0.2s;
    }
    input:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }
    .helper-text {
      color: #999;
      font-size: 12px;
      margin-top: 6px;
    }
    button {
      width: 100%;
      padding: 12px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    button:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
    }
    button:active {
      transform: translateY(0);
    }
    button:disabled {
      opacity: 0.7;
      cursor: not-allowed;
    }
    .success-message {
      display: none;
      background: #d4edda;
      color: #155724;
      padding: 16px;
      border-radius: 8px;
      margin-top: 20px;
      border: 1px solid #c3e6cb;
    }
    .success-message.show {
      display: block;
    }
    .info-box {
      background: #f0f7ff;
      border-left: 4px solid #667eea;
      padding: 16px;
      border-radius: 6px;
      margin-bottom: 24px;
      font-size: 13px;
      color: #333;
      line-height: 1.6;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Request Account Deletion</h1>
    <p class="subtitle">We're sorry to see you go. If you'd like to permanently delete your CasualMeets account and all associated data, please provide your email address or User ID below.</p>

    <div class="info-box">
      <strong>What happens when you delete your account?</strong><br>
      • All your profile information, photos, and messages will be permanently deleted<br>
      • Your account cannot be recovered after deletion<br>
      • We will process your request within 30 days
    </div>

    <form id="deletionForm">
      <div class="form-group">
        <label for="identifier">Email Address or User ID</label>
        <input
          type="text"
          id="identifier"
          name="identifier"
          placeholder="your.email@example.com or user-id"
          required
        >
        <div class="helper-text">Enter the email address or User ID associated with your CasualMeets account</div>
      </div>

      <button type="submit">Request Account Deletion</button>

      <div class="success-message" id="successMessage">
        <strong>Request Received</strong><br>
        Thank you for your deletion request. We will delete your account within 30 days. You will receive a confirmation email.
      </div>
    </form>
  </div>

  <script>
    document.getElementById('deletionForm').addEventListener('submit', async (e) => {
      e.preventDefault();
      const identifier = document.getElementById('identifier').value.trim();
      const button = e.target.querySelector('button[type="submit"]');

      if (!identifier) {
        alert('Please enter your email address or User ID');
        return;
      }

      button.disabled = true;
      button.textContent = 'Processing...';

      try {
        const response = await fetch('/api/account/deletion-request', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ identifier }),
        });

        if (response.ok) {
          document.getElementById('deletionForm').style.display = 'none';
          document.getElementById('successMessage').classList.add('show');
        } else {
          const error = await response.json().catch(() => ({ error: 'Request failed' }));
          alert('Error: ' + (error.error || 'Failed to process your request'));
          button.disabled = false;
          button.textContent = 'Request Account Deletion';
        }
      } catch (error) {
        alert('Error: ' + error.message);
        button.disabled = false;
        button.textContent = 'Request Account Deletion';
      }
    });
  </script>
</body>
</html>
`;

legal.get("/account-deletion", (c) => {
	return c.html(accountDeletionHTML);
});

legal.post("/api/account/deletion-request", async (c) => {
	try {
		const body = await c.req.json().catch(() => ({}));
		const identifier = (body.identifier || '').trim();

		if (!identifier) {
			return c.json({ error: "Email address or User ID is required" }, 400);
		}

		// Log deletion request
		console.log(
			`[Account Deletion Request] Identifier: ${identifier}, IP: ${c.req.header("cf-connecting-ip") || "unknown"}`
		);

		return c.json({
			success: true,
			message: "Account deletion request received. We will process it within 30 days.",
		});
	} catch (error) {
		console.error("[Account Deletion Request Error]", error);
		return c.json({ error: "Failed to process deletion request" }, 500);
	}
});

const childSafetyPolicyHTML = html`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Child Safety Standards Policy - CasualMeets</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", sans-serif;
      line-height: 1.6;
      max-width: 900px;
      margin: 0 auto;
      padding: 20px;
      color: #333;
      background: #f9f9f9;
    }
    .container {
      background: white;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    h1 {
      color: #000;
      margin-top: 0;
      font-size: 32px;
    }
    h2 {
      color: #222;
      margin-top: 30px;
      font-size: 20px;
      border-bottom: 2px solid #667eea;
      padding-bottom: 10px;
    }
    h3 {
      color: #333;
      font-size: 16px;
      margin-top: 20px;
    }
    .meta {
      color: #666;
      font-style: italic;
      margin-bottom: 30px;
      padding: 15px;
      background: #f0f7ff;
      border-left: 4px solid #667eea;
      border-radius: 4px;
    }
    p {
      margin: 12px 0;
    }
    ul, ol {
      margin: 15px 0;
      padding-left: 24px;
    }
    li {
      margin: 8px 0;
    }
    strong {
      color: #000;
    }
    .warning-box {
      background: #ffe0e0;
      border-left: 4px solid #d32f2f;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
      color: #333;
    }
    .contact-box {
      background: #e3f2fd;
      border-left: 4px solid #1976d2;
      padding: 20px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .contact-box strong {
      display: block;
      margin-bottom: 8px;
    }
    a {
      color: #1976d2;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    .last-updated {
      color: #999;
      font-size: 12px;
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #eee;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Child Safety Standards Policy</h1>

    <div class="meta">
      <strong>Effective Date:</strong> June 22, 2026<br>
      <strong>Published by:</strong> Neo Nebula
    </div>

    <p>CasualMeets is committed to providing a secure, responsible, and respectful environment for social discovery. We maintain a zero-tolerance stance against any form of child exploitation or abuse. This Child Safety Standards Policy outlines our mandatory rules, enforcement actions, and compliance protocols designed to combat Child Sexual Abuse and Exploitation (CSAE) and Child Sexual Abuse Material (CSAM).</p>

    <h2>1. Standards Against Child Sexual Abuse and Exploitation (CSAE)</h2>
    <p>CasualMeets is strictly an adult-only (18+) platform. The following actions are completely prohibited and will result in immediate, non-appealable termination of the offending user account:</p>
    <ul>
      <li>Engaging in, facilitating, or encouraging the sexual exploitation or abuse of children.</li>
      <li>Attempting to groom, manipulate, or contact minors for sexual purposes.</li>
      <li>Utilizing text, symbols, or hidden messaging to request, discuss, or organize activities related to the exploitation of minors.</li>
    </ul>

    <div class="warning-box">
      <strong>⚠️ Violation Consequences:</strong> Any confirmed violation will result in immediate account suspension, permanent ban, preservation of evidence, and mandatory reporting to law enforcement authorities.
    </div>

    <h2>2. Prohibition and Handling of Child Sexual Abuse Material (CSAM)</h2>
    <p>We strictly prohibit the uploading, transmission, sharing, or storage of Child Sexual Abuse Material (CSAM) across any part of our platform, including user profile cards, bio descriptions, and direct messaging channels.</p>

    <h3>Detection & Filtering</h3>
    <p>We employ automated metadata checks, image analysis, and backend architectural validations to prevent explicit content from being uploaded.</p>

    <h3>Immediate Removal</h3>
    <p>Any content flagged or identified as potentially containing CSAM is immediately hidden from public view and isolated for review. If verified, the content is permanently purged from active production directories, and the originating account is permanently banned via hardware and network device indexing.</p>

    <h2>3. In-App Reporting and Feedback Mechanisms</h2>
    <p>CasualMeets provides clear, always-accessible in-app reporting mechanics directly within the user interface:</p>
    <ul>
      <li>Users can flag any profile or direct message thread instantly using the in-app "Report" button.</li>
      <li>When submitting a report, users can explicitly select "Child Safety Concern" or "Inappropriate Content" to route the ticket directly to our priority moderation queue.</li>
      <li>All child safety reports are treated with the highest urgency and are reviewed by our systems administration team.</li>
    </ul>

    <h2>4. Legal Compliance and Global Law Enforcement Reporting</h2>
    <p>CasualMeets complies strictly with international and regional child protection laws.</p>
    <ul>
      <li>In accordance with global legal requirements, we do not merely delete verified CSAM data.</li>
      <li>We preserve the necessary forensic log footprints, device signatures, and account telemetry required by law enforcement.</li>
      <li>All confirmed instances of CSAM or active child grooming will be reported immediately to the National Center for Missing & Exploited Children (NCMEC) and relevant national and regional judicial authorities.</li>
    </ul>

    <h2>5. Child Safety Designated Point of Contact</h2>
    <p>For inquiries regarding our safety infrastructure, compliance updates, or coordinated law enforcement requests, our designated administrator can be reached directly:</p>

    <div class="contact-box">
      <strong>Email Contact:</strong> <a href="mailto:thabang.soulo@neonebula.co.za">thabang.soulo@neonebula.co.za</a><br>
      <strong>Organization:</strong> Neo Nebula<br>
      <strong>Availability:</strong> 24/7 for urgent law enforcement inquiries
    </div>

    <h2>6. Policy Updates and Enforcement</h2>
    <p>CasualMeets reserves the right to update this policy as needed to maintain compliance with evolving legal standards and best practices in child protection. Any material changes will be communicated to users through in-app notifications.</p>

    <p>This policy is enforced consistently and without exception. Users who violate any part of this policy will face immediate and permanent account termination, and their information will be preserved and reported to appropriate authorities as required by law.</p>

    <div class="last-updated">
      <p><strong>Last Updated:</strong> June 22, 2026</p>
      <p>For the most up-to-date version of this policy, visit: <strong>/child-safety-policy</strong></p>
    </div>
  </div>
</body>
</html>
`;

legal.get("/child-safety-policy", (c) => {
	return c.html(childSafetyPolicyHTML);
});
