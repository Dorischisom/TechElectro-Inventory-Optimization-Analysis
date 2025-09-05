# TechElectro Inventory Optimization: SQL-Driven Supply Chain Intelligence

## Background and Overview
TechElectro Inc., a global consumer electronics manufacturer and distributor established in 2006, faces critical inventory management challenges that directly impact operational efficiency and customer satisfaction. The company's extensive product portfolio spans smartphones, laptops, home appliances, and accessories across multiple international markets.

## Business Challenge
TechElectro experiences significant inventory inefficiencies including frequent overstocking of slow-moving products (tying up capital and storage capacity) and recurring stockouts of high-demand items (resulting in lost sales and customer dissatisfaction). These inventory imbalances have created a need for data-driven optimization to balance supply and demand effectively.

### Project Objectives:

- Implement SQL-driven inventory optimization to determine optimal stock levels for each product SKU
- Analyze sales trends and external economic factors influencing demand patterns
- Calculate dynamic reorder points and safety stock levels to minimize stockouts and overstock situations
- Establish automated monitoring systems for continuous inventory performance tracking

This analysis focuses on three core areas: **sales trend analysis, product-level performance evaluation, and economic factor** correlation to develop actionable inventory management strategies.

[View The SQL Codes used for this Analysis](TechElectrosql/TechElectrosql.sql)


## Data Structure Overview
The analysis utilizes three interconnected datasets representing TechElectro's comprehensive business ecosystem:

# Database Schema

#### Table 1: Sales Data (15,847 transaction records across 1,258 unique products over 667 days)

| Column Name              | Key         | Data Type | Description                                      |
|---------------------------|-------------|-----------|--------------------------------------------------|
| ProductID                 | Foreign Key | Integer   | Unique product identifier. References **Product Information Data**. |
| SalesDate                 |             | Date      | Date of product sale. Format: YYYY-MM-DD.        |
| SalesQuantity             |             | Integer   | Number of units sold. Units.                     |
| ProductCost               |             | Decimal   | Cost per product unit. Units: USD per Unit.      |

---

#### Table 2: Product Information Data (Complete product catalog with category classifications and promotion status)

| Column Name      | Key          | Data Type | Description                                |
|------------------|--------------|-----------|--------------------------------------------|
| ProductID        | Primary Key  | Integer   | Unique product identifier.                  |
| ProductCategory  |              | Text      | Type/category of the product.              |
| Promotions       |              | Boolean   | Indicator of promotions (Yes/No).          |

---

#### Table 3: External Information Data (Daily economic indicators including GDP, inflation rates, and seasonal adjustment factors)

| Column Name      | Key         | Data Type | Description                                          |
|------------------|-------------|-----------|------------------------------------------------------|
| SalesDate        | Primary Key | Date      | Date of product sale. Format: YYYY-MM-DD.            |
| GDP              |             | Decimal   | Gross Domestic Product. Units: USD.                  |
| InflationRate    |             | Decimal   | Percentage change in prices. Units: %.               |
| SeasonalFactor   |             | Decimal   | Index for seasonal effects. Dimensionless.           |

The integrated dataset enables comprehensive analysis of inventory performance across customer demographics (regional/currency variations), product characteristics (categories/pricing), and temporal patterns (seasonal/economic cycles).

#### Tools Used:

- MySQL 8.0 for data integration and analysis
- SQL window functions for rolling average calculations
- Stored procedures for automated reorder point recalculation
- Database triggers for real-time inventory optimization updates

### Key SQL Components:

- Data cleaning and standardization procedures
- Advanced window functions for trend analysis
- Automated reorder point calculation system
- Real-time monitoring stored procedures

## Executive Summary

### Key Findings: 

Analysis of TechElectro's inventory data reveals systemic optimization opportunities across product categories. The company maintains generally healthy inventory levels with zero recorded stockouts among high-demand products, indicating conservative stocking strategies that may be overshooting optimal levels.

#### Critical Insights:

- **Inventory Balance:** No stockouts identified in high-demand products (top 5% by sales volume), suggesting potential overstocking
- **Economic Correlation:** Sales performance shows direct correlation with positive GDP periods, indicating economic sensitivity
- **Product Performance:** Significant variance in product profitability with Product ID 2010 generating $19,669 in total sales versus Product ID 8821 at $17
- **Optimization Potential:** Current reorder points calculated using rolling 7-day averages and 95% service levels show opportunities for capital efficiency improvements
- **Business Impact:** Implementation of calculated reorder points could optimize working capital allocation while maintaining service levels. The analysis identifies specific products requiring immediate attention for both overstock reduction and demand forecasting refinement.

## Insights Deep Dive

### Sales Performance Analysis

- **Top-Performing Products:** **Product ID 2010** emerged as the highest revenue generator with **$19,669** in total sales, while maintaining consistent demand patterns across the analysis period. The rolling **7-day sales average** for this product showed minimal volatility, indicating predictable demand suitable for optimized inventory planning.

- **Product Category Performance:** Electronics categories demonstrated varying performance with **smartphones and laptops** showing higher average order values but slower inventory turnover compared to accessories. This pattern suggests category-specific inventory strategies may be more effective than universal approaches.

- **Seasonal and Economic Influences:** Sales data correlation with external factors revealed that products perform consistently better during positive GDP growth periods. However, the analysis found no sales data during negative or neutral GDP periods, suggesting either data limitations or that TechElectro's market positioning provides protection during economic downturns.

### Inventory Optimization Calculations
- **Reorder Point Methodology:** Using statistical analysis, optimal reorder points were calculated for each product using the formula: `Reorder Point = (Rolling Average Sales × Lead Time) + Safety Stock`.
Assuming a **7-day lead time and 95% service level**, reorder points range from **42 units** for low-demand accessories to **13,477 units** for high-volume products.

- **Safety Stock Analysis:** Most products showed zero variance in daily sales patterns, resulting in minimal safety stock requirements. This finding suggests either highly predictable demand or potential data quality considerations that warrant further investigation.

- **Economic Factor Integration:** The analysis incorporated GDP, inflation rate, and seasonal factors into demand forecasting models. Products showed consistent positive correlation with economic growth indicators, enabling more sophisticated demand predictions for inventory planning.

## Recommendations

### Immediate Actions:

- **Implement Dynamic Reorder Points:** Deploy the calculated reorder points immediately for the **top 20%** of products by revenue. This focused approach will optimize approximately 80% of inventory value while allowing for gradual system refinement.
- **Establish Overstock Reduction Program:** Products with inventory values consistently exceeding **150%** of rolling sales averages should be flagged for promotional campaigns, bundle offerings, or strategic price adjustments to accelerate turnover.
- **Economic Indicator Integration:** Develop automated inventory adjustments based on GDP growth forecasts and seasonal factors. During projected positive GDP periods, increase safety stock by **15-20%** for high-demand categories.

### Strategic Initiatives:

- **Category-Specific Optimization:** Implement differentiated inventory strategies by product category, with electronics requiring longer lead times and higher safety stocks compared to fast-moving accessories.
- **Feedback Loop Implementation:** Establish monthly stakeholder reviews to assess inventory optimization performance and refine reorder calculations based on actual demand patterns and market changes.
- **Automated Monitoring System:** Deploy the created SQL stored procedures (MonitorInventoryLevels, MonitorSalesTrends, MonitorStockouts) to provide real-time inventory performance dashboards for operations teams.

