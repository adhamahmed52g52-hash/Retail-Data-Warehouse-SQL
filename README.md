# Superstore Retail Data Warehouse & SQL Analytics

## 📌 Project Overview
This project transforms raw transactional retail data from the Central Superstore dataset into an optimized analytical relational database using a **Star Schema** architecture in SQL Server. It covers the full lifecycle of dimensional modeling, data transformation, KPI reporting, and performance optimization.

---

## 🏗️ Data Architecture (Star Schema)
The data warehouse is designed with 1 central Fact table and 4 Dimension tables:
* **Fact_Orders:** Contains transactional sales metrics (Sales, Profit, Quantity, Discount) and foreign keys referencing dimensions.
* **S_Customer:** Customer demographic information and market segmentation.
* **S_Product:** Product catalog and category hierarchy (Category, Sub-Category).
* **S_Location:** Geographical data (City, State, Region, Postal Code).
* **S_ShipMode:** Fulfillment modes and shipping classifications.

---

## 🚀 Key SQL Features Implemented
* **Relational Data Modeling:** Defined primary and foreign keys establishing referential integrity.
* **Business Analytics & EDA:** Aggregated multi-table queries analyzing revenue, category profitability, and customer lifetime value.
* **CTEs & Window Functions:** Segmented customer purchase rankings and categorized order profitability.
* **Views:** `View_State_Performance` for persistent geographical KPI tracking.
* **Stored Procedures:** `sp_Get_State___Report` providing parameterized executive summaries per state.
* **Performance Optimization:** Non-clustered indexes created on dimension foreign keys in `Fact_Orders` to accelerate join operations.

---

## 📈 Key Business Insights
* **Discount Vulnerability:** States like Texas and Illinois incur net negative profits driven by steep average discount rates (>35%).
* **Product Profit Drivers:** Technology remains the highest margin category, whereas certain Furniture sub-categories require discount caps to avoid losses.

---

## 👤 Author
* **Name:** Adham Ahmed Mohamed Mohamed
* **Track:** Data Analysis
