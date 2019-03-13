import 'package:flutter/material.dart';
import 'package:yadda/utils/uidata.dart';

class TermsAndConditions extends StatefulWidget {
  TermsAndConditions({
    Key key,
    this.i,
  }) : super(key: key);
  final int i;

  @override
  TermsAndConditionsState createState() => TermsAndConditionsState();
}

class TermsAndConditionsState extends State<TermsAndConditions>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIData.dark,
      appBar: new AppBar(
        iconTheme: IconThemeData(color: UIData.blackOrWhite),
        title: new Text(
          "Policies & Agreements",
          style: new TextStyle(
              fontSize: UIData.fontSize24, color: UIData.blackOrWhite),
        ),
        backgroundColor: UIData.appBarColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "Terms & Conditions",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
            ),
            Tab(
              child: Text(
                "Privacy Policy",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
            ),
            Tab(
              child: Text(
                "EULA",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
            ),
          ],
        ),
      ),
      body: new TabBarView(
        physics: ScrollPhysics(),
        controller: _tabController,
        children: [
          new Padding(
            padding: EdgeInsets.all(16.0),
            child: new SingleChildScrollView(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: page(1)),
            ),
          ),
          new Padding(
            padding: EdgeInsets.all(16.0),
            child: new SingleChildScrollView(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: page(2)),
            ),
          ),
          new Padding(
            padding: EdgeInsets.all(16.0),
            child: new SingleChildScrollView(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: page(3)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> page(i) {
    switch (i) {
      case 1:
        return [
          new Text(
            "1. Agreement to Terms",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "1.1 These Terms and Conditions consitute a legally binding agreement made between you, whether personally or on behalf of an entity (you), and Preflop, located at Sandertunet 115, Ski, Akershus 1400 Norway (we, us), concerning your access to and use of Preflop, as well as any related applications.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "The Application provides the following services: A support application for live poker games (Services). You agree that by accessing the application and/or services, you have read, understood, and agree to be bound by all of these Terms and Conditions.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "If you do not agree with all of these Terms And Conditions, then you are prohibited from using the Application and Services and you must discontinue use immediately. We recommend that you print a copy of these Terms And Conditions for future reference.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "1.2 The supplemental policies set out in Section 1.7 below, as well as any supplemental terms and condition or documents that may be posted on the application from time to time, are expressly incorporated by reference.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            '1.3 We may make changes to these Terms and Conditions at any time. The updated version of these Terms and Conditions will be indicated by an updated "Revised" date and the updated version will be effective as soon as it is accessible. You are responsible for reviewing these Terms And Conditions to stay informed on updates. Your continued use of the application represents that you have accepted such changes.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "1.4 We may update or change the application from time to time to reflect changes to our products, our users' needs and/or our business priorities.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "1.5 Our application is directed to people residing in United Kingdom. The information provided on the application is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would be subject to us to any registration requirement within such jurisdiction or country.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "1.6 The application is intended for users who are at least 18 years old. If your and under the age of 18, you are not permitted to register for the application or use the services without parental permission.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Our Privacy Notice https://www.digitaleunge.com/, which sets out the terms on which we process any personal data we collect from you, or that you provide us. By using the application, you consent to such processing and you warrant that all data provided by you is accurate.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Certain parts of this application can be used only on a payment of a fee.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "2. Acceptable Use",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "2.1 You may not access or use the application for any purpose other than that for which we make the application and our services available. The application may not be used in connection with any commercial endeavours except those that are specifically endorsed or approved by us.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "2.2 As a user of this site you agree not to:",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Systematically retrieve data or other content from the application to compile a database or directory without written permission from us. \n\nMake any unauthorized use of the application, including collecting usernames and/or email addresses of users to send unsolicited email or creating user accounts under false pretenses. \n\nUse the application to advertise or sell goods and services\n\nCircumvent, disable or otherwise interfere with security-related features of the application, including features that prevent or restrict the use or copying of any content or enforce limitations on the use.\n\nEngage in unauthorized framing of or linking to the application. \n\nTrick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passords.\n\nMake improper use of our support services, or submit false reports of abuse or misconduct.\n\nEngage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots or similar data gathering and extraction tools. \n\nInterfere with, disrupt, or create an undue burden on the application or the networks and services connected to the application.\n\nAttempt to impersonate another user or person, or use the username of another user.\n\nSell or otherwise transfer your profile.\n\nUse any information obtained from the application in order to harass, abuse or harm another person.\n\nUse the application or our content as part of any effort to compete with us or to create a revenue-generating endeavor or commercial enterprise.\n\nDecipher, decompile, disassemble, or reverse engineer any of the software compromising or in any way making up a part of the application.\n\nAttempt to access any portions of the application that you are restricted from accessing.\n\nHarass, annoy, initimidate, or threaten any of our employees, agents or other users.\n\nDelete the copyright or other proprietary rights notice from any of the content.\n\nCopy or adapt the application's software, including but not limited to Flash, PHP, HTML, JavaScript, or other code.\n\nUpload or transmit (or attempt to upload or to transmit) viruses, Trojan horses, or other material that interferes with any party's uninterrupted use and enjoyment of the application, or any material that acts as a passive or active information collection or transmission mechanism.\n\nUse, launch, or engage in any automated use of the system, such as scripts to send comments or messages, robots, scrapers, offline readers, or similar data gathering and extraction tools.\n\nDisparage, tarnish, or otherwise harm, in our opinion, us and/or the application.\n\nUse the application in a manner inconsistent with any applicable laws or regulations.\n\nThreaten users with negative feedback or offering services solely to give positive feedback to users.\n\nUse a buying agent or purchasing agent to make purchases on the application.\n\nFalsely implying a relationship with us or another company with whom you do not have a relationship.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "3. Information you provide to us",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "3.1 You represent and warrant that: (a) all registration information you submit will be true, accurate, current, and complete and relate to you not a third party; (b) you will maintain the accuracy of such information and promptly update such information as necessary; (c) you will keep your password confidential and will be responsible for all use of your password and account; (d) you have the legal capacity and you agree to comply with these Terms and Conditions; and (e) you are not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission tu use this application. \n\nIf you know or suspect that anyone other than you knows your user information (such as an identification code or user name) and/or password you must promptly notify us at preflopapp@gmail.com",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "3.2 If you provide any information that is untrue, inaccurate, not current or incomplete, we may suspend or terminate your account. We may remove or change a user name you select if we determine that such user name is inappropriate.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4. Content you provide to us",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.1 There may be opportunities for you to post content to the application or send feedback to us (User Content). You understand and agree that your User Content may be viewed by other users on the application, and that they may be able to see who has posted that User Content.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.2 In posting User Content, including reviews or making contact with other users of the application you shall comply with our Acceptable Use Policy.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.3 You warrant that any User Content does comply with our Acceptable Use Policy, and you will be liable to us and indemnify us for any breach of that warranty. This means you will be responsible for any loss or damage we suffer as a result of your breach of this warranty.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.4 We have the right to remove any User Content you put on the application if, in our opinion, such User Content does not comply with the Acceptable Use Policy.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.5 We are not responsible and accept no liability for any User Content including any such content that contains incorrect information or is defamatory or loss of User Content. We accept no obligation to screen, edit or monitor any User Content but we reserve the right to remove, screen and/or edit any User Content without notice and at any time. User Content has not been verified or approved by us and the views expressed by any other users on the application do not represent our views or values.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "4.6 If you wish to complain about User Content uploaded by other users please contact us at preflopapp@gmail.com",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5. Our content",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.1 Unless otherwise indicated, the application and services including source code, databases, functionality, software, application designs, audio, video, text, photographs, and graphics on the application (Our Content) are owned or licensed to us, and are protected by copyright and trade mark laws.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.2 Except as expressly provided in these Terms and Conditions, no part of the application, services or Our Content may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.3 Provided that you are eligible to use the application, you are granted a limited license to access and use the application and Our Content and to download or print a copy of any portion of the Content to which you have properly gained access and solely for your personal, non-commercial use.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.4 You shall not (a) try to gain unauthorised access to the application or any networks, servers or computer systems connected to the application; and/or (b) make for any purpose including error correction, any modifications, adaptions, additions or enhancements to the application or Our Content, including the modification of the paper or digital copies you may have downloaded.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.5 We shall (a) prepare the application and Our Content with reasonable skill and care; and (b) use industry standard virus detection software to try to black the uploading of content to the application that contains viruses.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.6 The content on the application is provided for general information only. It is not intended to amount to advice on which you should rely. You must obtain professional or special advice before taking, or refraining from, any action on the basis of the content on the application.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "5.7 Although we make reasonable efforts to update the information on our site, we make no representations, warranties or guarantees, whether express or implied, that Our Content is accurate, complete or up to date.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "6. Link to third party content",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "6.1 The application may contain links to websites or applications operated by third parties. We do not have any influence or control over any such third party websites or applications or the third party operator. We are not responsible for and do not endorse any third party websites or applications or their availability or content.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "6.2 We accept no responsibility for adverts contained within the application. If you agree to purchase goods and/or services from any third party who advertises in the application, you do so at your own risk. The advertiser, and not us, is responsible for such good and/or services and if you have any questions or complaints in relation to them, you should contact the advertiser.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "7. Application Management",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "7.1 We reserve the right at our sole discretion, to (1) monitor the application for breaches of these Terms and Conditions; (2) take appropriate legal action against anyone in breach of applicable laws or these Terms and Conditions; (3) refuse, restrict access to or availability of, or disable (to the extent technologically feasible) any of your Contributions; (4) remove from the application or otherwise disable all files and content that are excessive in size or are in any way a burden to our systems; and (5) otherwise manage the application in a manner designed to protect our rights and property and to facilitate the proper functioning of the application and services.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "7.2 We do not guarantee that the application will be secure or free from bugs or viruses.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "7.3 You are responsible for configuring your information technology, computer programs and platform to access the application and you should use your own virus protection software.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "8. Modifications to and availability of the Application",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "8.1 We reserve right to change, modify, or remove the contents of the application at any time or for any reason at our sole discretion without notice. We also reserve the right to modify or discontinue all or part of the services without notice at any time.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "8.2 We cannot guarantee the application and services will be available at all times. We may experience hardware, software, or other problems or need to perform maintenance related to the application, resulting in interruptions, delays, or errors. You agree that we have no liability whatsoever for any loss, damage, or inconvenience caused by your inability to access or use the application or services during any downtime or discontinuance of the application or services. We are not obliged to maintain and support the application and services or to supply any corrections, updates, or releases.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "8.3 There may be information on the application that contains typographical errors, inaccuracies, or omissions that may relate to the services, including descriptions, pricing, availability, and various other information. We reserve the right to correct any errors, inaccuracies, or omissions and to change or update the information at any time, without prior notice.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "9. Disclaimer/Limitation of Liability",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "9.1 The application and services are provided on an as-is and as-available basis. You agree that your use of the application and/or services will be at your sole risk except as expressly set out in these Terms and Conditions, all warrantied, terms, conditions and undertakings, express or implied (including by statute, custom or usage, a course of dealing, or common law) in connection with the application and services and your use thereof including, without limitation, the implied warranties of satisfactory quality, fitness for a particular purpose and non-infringement are excluded to the fullest extent permitted by applicable law.\n\nWe make no warranties or representations about the accuracy or completeness of the application's content are not liable for any (1) errors or omissions in content: (2) any unauthorized access to or use of our servers and/or any and all person information and/or financial information stored on our server; (3) any interruption or cessation of transmission to or from the site or services; and/or (4) any bugs, viruses, trojan horses, or the like which may be transmitted to or through the site by any third party. We will not be responsible for any delay or failure to comply with our obligations under these Terms and Conditions if such delay or failure is caused by an event beyond our reasonable control.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "9.2 Our responsibility for loss or damage suffered by you: \n\nWhether you are a consumer or a business user: \n\nWe do not exclude or limit in any way our liability to you where it would be unlawful to do so. This includes liability for death or personal injury caused by our negligence or the negligence of our employees, agents or subcontractors and for fraud or fraudulent misrepresentation. \n\nIf we fail to comply with these Terms and Conditions, we will be responsible for loss or damage you suffer that is a foreseeable result of our breach of these Terms and Conditions, but we would not be responsible for any loss or damage that were not foreseeable at the time you started using the application/services.\n\nNotwithstanding anything to the contrary contained in the Disclaimer/Limitation of Liability section, our liability to you for any cause whatsoever and regardless of the form of the action, will at all times be limited to a total aggregate amount equal to the greater of (a) the sum of £5000 or (b) the amount paid, if any, by you to us for the services/application during the six (6) month period prior to any cause of action arising. \n\nIf you are a consumer user:\n\nPlease note that we only provide our application for domestic and private use. You agree not to use our application for any commercial or business purposes, and we have no liability for any loss of profit, loss of business, business interruption, or loss of business opportunity. \n\nIf defective digital content that we have supplied, damages a device or a digitalt content belonging to you and this is causes by our failure to use reasonable care and skill, we will either repair the damage or pay you compensation. \n\nYou have legal rights in relation to goods that are faulty or not as described. Advice about your legal rights is available from your local Citizens' Advice Bureau or Trading Standards office. Nothing in these Terms and Conditions will affect these legal rights.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "10. Term and Termination",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "10.1 These Terms and Conditions shall remain in full force and effect while you use the application or services or are otherwise a user of the application, as applicable. You may terminate your use or participation at any time, for any reason, by following the instructions for terminating user accounts in your account settings, if available or by contacting us at preflopapp@gmail.com",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "10.2 Without limiting any other provision of these Terms and Conditions, we reserve the right to, in our sole discretion and without notice or liability, deny access to and use of the application and services (including blocking certain devices), to any person for any reason including without limitation for breach of any representation, warranty or covenant contained in these Terms and Conditions or any of applicable law or regulation.\n\nIf we determine, in our sole discretion, that your use of the application/services is in breach of these Terms and Conditions or of any applicable law or regulation, we may terminate your use or participation in the application and the services or delete your profile and any content or information that you posted at any time, without warning, in our sole discretion.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "10.3 If we terminate or suspend your account for any reason set out in this Section 9, you are prohibited from registering and creating a new account under your name, a fake or borrowed name, or the name of any third party, even if you may be acting on behalf of the third party. In addition to terminating or suspending your account, we reserve the right to take appropriate legal action, including without limitation pursuing civil, criminal, and injunctive redress.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "11. Mobile Application",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "11.1 If you access the services via a mobile application, then we grant you a revocable, non-exclusive, non-transferable, limited right to install and use the mobile application on wireless electronic devices owned or controlled by you, and to access and use the mobile application on such devices strictly in accordance with the terms and conditions of this license.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "11.2 For consumers only - If you are a customer in the European Union, you have certain rights to decompile the software if:\n\nThis is necessary to obtain the information that you need to make the software interoperable with other software and we have not made that information available to you.\n\nBefore reverse engineering or decompiling the software, you must first write to us and ask us to provide you with the interoperability information that you need. Please provide us with full details of your requirements so that we can assess what information you need. We may impose reasonable conditions on providing you with interoperability information. You must use that information only for the purpose of making the software interoperable with other software. You must not use that information for any other purpose.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            '11.3 The following terms apply when you use a mobile application obtained from either the Apple Store or Google Play (each an App Distributor) to access the services:\n\n(a) the licence granted to you for our mobile application is limited to a non-transferable licence to use the application on a device that utilizes the Apple iOS or Android operating system, as applicable, and in accordance with the usage rules set forth in the applicable App Distributor terms of service.\n\n(b) we are responsible for providing any maintenance and support services with respect to the mobile application as specified in these Terms and Conditions or as otherwise required under applicable law. You acknowledge that each App Distributor has no obligation whatsoever to furnish any maintenance and support services with respect to the mobile application;\n\n(c) In the event of any failure of the mobile application to conform to any applicable warranty, you may notify an App Distributor, and the App Distributor, in accordance with its terms and policies, may refund the purchase price, if any, paid for the mobile application, and to the maximum extent permitted by applicable law, an App Distributor will have no other warranty obligation whatsoever with respect to the mobile application;\n\n(d) you represent and warrant that (i) you are not located in a country that is subject to a U.S. government embargo, or that has been designated by the U.S. government as a "terrorist supporting" country; and (ii) you are not listed on any U.S. government list of prohibited or restricted parties;\n\n(e) you must comply with applicable third party terms of agreement when using the mobile application, e.g. if you have a VoIP application, then you must not be in breach of their wireless data service agreement when using the mobile application; and\n\n(f) you acknowledge and agree that the App Distributors are third party beneficiaries of these Terms and Conditions, and that each App Distributor will have the right (and will be deemed to have accepted the right) to enforce these Terms and Conditions against you as a third party beneficiary thereof.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "12. General",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "12.1 Visiting the application, sending us emails, and completing online forms constitute electronic communications. You consent to receive electronic communications and you agree that all agreements, notices, disclosures, and other communications we provide to you electronically, via email and on the application, satisfy any legal requirement that such communication be in writing.\n\nYou hereby agree to the use of electronic signatures, contracts, orders and other records and to electronic delivery of notices, policies and records of transactions initiated or completed by us or via the application. You hereby waive any rights or requirements under any statutes, regulations, rules, ordinances or other laws in any jurisdiction which require an original signature or delivery or retention of non-electronic records, or to payments or the granting of credits by other than electronic means.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "12.2 These Terms and Conditions and any policies or operating rules posted by us on the application or in respect to the services constitute the entire agreement and understanding between you and us.\n\n12.3 Our failure to exercise or enforce any right or provision of these Terms and Conditions shall not operate as a waiver of such right or provision.\n\n12.4 We may assign any or all of our rights and obligations to others at any time.\n\n12.5 We shall not be responsible or liable for any loss, damage, delay or failure to act caused by any cause beyond our reasonable control.\n\n12.6 If any provision or part of a provision of these Terms and Conditions is unlawful, void or unenforceable, that provision or part of the provision is deemed severable from these Terms and Conditions and does not affect the validity and enforceability of any remaining provisions.\n\n12.7 There is no joint venture, partnership, employment or agency relationship created between you and us as a result of these Terms and Conditions or use of the application or services.\n\n12.8 For consumers only - Please note that these Terms and Conditions, their subject matter and their formation, are governed by English law. You and we both agree that the courts of England and Wales will have exclusive jurisdiction expect that if you are a resident of Northern Ireland you may also bring proceedings in Northern Ireland, and if you are resident of Scotland, you may also bring proceedings in Scotland. If you have any complaint or wish to raise a dispute under these Terms and Conditions or otherwise in relation to the application please follow this link http://ec.europa.eu/odr \n\n12.9 Except as stated under the Mobile Application section, a person who is not a party to these Terms and Conditions shall have no right under the Contracts (Rights of Third Parties) Act 1999 to enforce any term of these Terms And Conditions.\n\n12.10 In order to resolve a complaint regarding the services or to receive further information regarding the use of the services, please contact us by email at preflopapp@gmail.com or by post to:\n\nPreflop\nSandertunet 155\nSki, Akershus 1400\nNorway",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
        ];

        break;
      case (2):
        return [
          new Text(
            "Privacy Policy",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Ulrik Haland built the Preflop app as a Freemium app. This SERVICE is provided by Ulrik Haland at no cost and is intended for use as is.\n\nThis page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.\n\nIf you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Preflop unless otherwise defined in this Privacy Policy.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Information Collection and Use",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Email. The information that I request will be retained on your device and is not collected by me in any way.\n\nThe app does use third party services that may collect information used to identify you.\n\nA link to privacy policy of third party service providers used by the app can be found at https://www.digitaleunge.com/\n\nI want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Cookies",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device’s internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Service Providers",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "I may employ third-party companies and individuals due to the following reasons:\n\nTo facilitate our Service;\nTo provide the Service on our behalf;\nTo perform Service-related services; or\nTo assist us in analyzing how our Service is used.\n\nI want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Security",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Links to Other Sites",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Children’s Privacy",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do necessary actions.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Changes to This Privacy Policy",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Contact Us",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact us at preflopapp@gmail.com.",
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
        ];
        break;
      case (3):
        return [
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "End-User License Agreement (EULA) of Preflop",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            'This End-User License Agreement ("EULA") is a legal agreement between you and Galante\n\nThis EULA agreement governs your acquisition and use of our Preflop software ("Software") directly from Galante or indirectly through a Galante authorized reseller or distributor (a "Reseller").\n\nPlease read this EULA agreement carefully before completing the installation process and using the Preflop software. It provides a license to use the Preflop software and contains warranty information and liability disclaimers.\n\nIf you register for a free trial of the Preflop software, this EULA agreement will also govern that trial. By clicking "accept" or installing and/or using the Preflop software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement.\n\nIf you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.\n\nThis EULA agreement shall apply only to the Software supplied by Galante herewith regardless of whether other software is referred to or described herein. The terms also apply to any Galante updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply. This EULA was created by EULA Template for Preflop.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "License Grant",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            'Galante hereby grants you a personal, non-transferable, non-exclusive licence to use the Preflop software on your devices in accordance with the terms of this EULA agreement.\n\nYou are permitted to load the Preflop software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum requirements of the Preflop software.\n\nYou are not permitted to:\n\nEdit, alter, modify, adapt, translate or otherwise change the whole or any part of the Software nor permit the whole or any part of the Software to be combined with or become incorporated in any other software, nor decompile, disassemble or reverse engineer the Software or attempt to do any such things\n\nReproduce, copy, distribute, resell or otherwise use the Software for any commercial purpose\n\nAllow any third party to use the Software on behalf of or for the benefit of any third party\n\nUse the Software in any way which breaches any applicable local, national or international law\n\nuse the Software for any purpose that Galante considers is a breach of this EULA agreement',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Intellectual Property and Ownership",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            'Galante shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Galante.\n\nGalante reserves the right to grant licences to use the Software to third parties.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Termination",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            'This EULA agreement is effective from the date you first use the Software and shall continue until terminated. You may terminate it at any time upon written notice to Galante.\n\nIt will also terminate immediately if you fail to comply with any term of this EULA agreement. Upon such termination, the licenses granted by this EULA agreement will immediately terminate and you agree to stop all access and use of the Software. The provisions that by their nature continue and survive will survive any termination of this EULA agreement.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            "Governing Law",
            style: new TextStyle(
                fontSize: UIData.fontSize20,
                color: UIData.blackOrWhite,
                fontWeight: FontWeight.bold),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          new Text(
            'This EULA agreement, and any dispute arising out of or in connection with this EULA agreement, shall be governed by and construed in accordance with the laws of no.',
            style: new TextStyle(
                fontSize: UIData.fontSize16, color: UIData.blackOrWhite),
          ),
          new Padding(
            padding: EdgeInsets.only(top: 12),
          ),
        ];
      default:
    }
  }
}
