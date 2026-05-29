# SQL-Social-Media-Analysis
A SQL-based analysis of social media metrics, focusing on user engagement, post performance, and audience growth trends
Instagram User Engagement & Interaction Analysis
An end-to-end SQL-driven data analytics project collaborating with the Meta Marketing team to analyze user behavior, platform retention, and interaction trends using a mock Instagram database schema (ig_clone).

📌 Project Overview
The Meta Marketing team wants to leverage Instagram's user data to develop targeted marketing strategies that will increase user engagement, retention, and acquisition.This project focuses on diving deep into backend database structures to uncover audience segments, peak interaction timelines, and content performance metrics.

🛠️ Tech Stack & Concepts Used
Database Management System:** MySQL Workbench
SQL Techniques:Multi-table JOINs to link relational structures
Common Table Expressions (CTEs) & Subqueries for performance optimization
Window Functions (RANK(), DENSE_RANK()) for user behavior ranking
Aggregate Functions (COUNT, AVG) paired with conditional grouping

🗄️ Database Schema & Data Description
The analysis was performed across 7 related tables capturing critical interaction attributes;

users: Platform registration and profile handles photos: Image posts and creator tracking
likes: Post-level user appreciations comments: Textual interactions left on posts
follows: Network relationship mapping (followers vs. followees) tags&photo_tags`: Metadata linking hashtags to posted images

Dataset Summary Metrics:
Users: 100
Photos/Posts:257
Likes: 8,782
Comments:7,488
Follows:7,623
Tags:21 unique tags mapping across 501 photos

📈 Key Insights & Analytical Findings
1. User Engagement Segmentation
Users were classified based on platform activity thresholds into three key groups
Active Users (30%):High-performing power users driving core metrics
Moderately Active Users (34%): Medium-engaged users who interact steadily
Inactive Users (36%):Low-engaged or dormant users representing a prime target for retention campaigns

2. Influencer & Power Contributor Mapping
Using RANK() across consolidated interaction counts, the top platform influencers were mapped to identify potential brand ambassadors.

Top Influencers identified:
Eveline95, Cesar93, Clint27, Delfina_VonRueden68, and Aurelie71.

3. Temporal Engagement Patterns (Weekday vs. Hours)
Peak Days:Engagement peaks dramatically on Thursdays (1,727 interactions) and Wednesdays (1,571 interactions)[cite: 255].
Peak Hours:Platform traffic clusters heavily between 5 PM (1,120) and 11 PM (1,249), while dropping drastically between 12 AM and 10 AM.

4. Content Tag Diagnostics
High-Performing Content: Scenic and culinary tags—such as #delicious, #food, #sunset, and #beauty—lead with the highest average engagement ratios[cite: 332, 333, 334, 335, 353].
Low-Performing Content: Event-based situational tags like #party and #concert underperform significantly.

🚀 Strategic Business Recommendations
🎯 Dormant User Activation:Run push-notification and email re-engagement campaigns focusing on account milestones or interactive friend activity to tap into the 36% inactive cohort
💎 Creator Loyalty Perks:Establish an official 'Super User' or creator ambassador program for the top 10% highly active users to sustain high-value production.
⏰ Ad Campaign Scheduling:Align major marketing drops, product ads, and live events squarely with the Wednesday/Thursday evening windows (5 PM – 11 PM) to optimize spend ROI].
🏷️ Tag Optimization:Shift creative strategy to blend aesthetic, lifestyle, and food visual themes while scaling back or refining underperforming event tags.

📂 Project Structure
├── Database_Schema/           # Database diagram and relation layouts
├── SQL_Queries/               # Compiled script file (.sql) containing all analytical queries
├── Presentation/              # Copy of the final project summary deck (.pdf)
└── README.md                  # Detailed overview of the project
Comment
You're receiving notifications becaus
