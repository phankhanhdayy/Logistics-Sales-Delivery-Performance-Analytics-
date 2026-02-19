import pandas as pd

# ======================================================
# ĐỌC DỮ LIỆU
# ======================================================

products = pd.read_csv("gold.report_products.csv")
sales = pd.read_csv("gold.fact_sales.csv")

sales.columns = sales.columns.str.strip().str.lower()

# ======================================================
# MERGE DỮ LIỆU
# ======================================================

df = sales.merge(products, on="product_key", how="left")

# ======================================================
# KPI THEO SẢN PHẨM
# ======================================================

product_perf = df.groupby("product_name").agg(
    total_revenue=("sales_amount", "sum"),
    total_quantity=("quantity", "sum"),
    total_orders=("order_number", "nunique")
).sort_values("total_revenue", ascending=False)

print("========== TOP SẢN PHẨM THEO DOANH THU ==========")
print(product_perf.head(10))

# ======================================================
# TOP & BOTTOM PRODUCT
# ======================================================

print("\nSẢN PHẨM DOANH THU CAO NHẤT:")
print(product_perf.idxmax())

print("\nSẢN PHẨM DOANH THU THẤP NHẤT:")
print(product_perf.idxmin())

# ======================================================
# PHÂN TÍCH THEO CATEGORY
# ======================================================

category_perf = df.groupby("category").agg(
    total_revenue=("sales_amount", "sum"),
    total_quantity=("quantity", "sum")
).sort_values("total_revenue", ascending=False)

print("\n========== DOANH THU THEO CATEGORY ==========")
print(category_perf)

# ======================================================
# SẢN PHẨM BÁN CHẠY NHẤT (THEO SỐ LƯỢNG)
# ======================================================

best_selling = product_perf.sort_values("total_quantity", ascending=False)

print("\n========== SẢN PHẨM BÁN CHẠY NHẤT ==========")
print(best_selling.head(10))

# ======================================================
# AVERAGE ORDER VALUE THEO SẢN PHẨM
# ======================================================

product_perf["aov"] = (
    product_perf["total_revenue"] / product_perf["total_orders"]
)

print("\n========== AOV THEO SẢN PHẨM ==========")
print(product_perf.sort_values("aov", ascending=False).head(10))

# ======================================================
# PARETO 80/20
# ======================================================

product_perf["revenue_pct"] = (
    product_perf["total_revenue"] / product_perf["total_revenue"].sum()
)

product_perf["cum_pct"] = product_perf["revenue_pct"].cumsum()

pareto_products = product_perf[product_perf["cum_pct"] <= 0.8]

print("\n========== PARETO 80/20 ==========")
print("Số sản phẩm tạo ra 80% doanh thu:", len(pareto_products))

# ======================================================
# PHÂN KHÚC SẢN PHẨM THEO DOANH THU
# ======================================================

product_perf["segment"] = pd.qcut(
    product_perf["total_revenue"],
    q=3,
    labels=["Low Performer", "Mid Performer", "High Performer"]
)

segment_summary = product_perf.groupby("segment")["total_revenue"].sum()

print("\n========== PHÂN KHÚC SẢN PHẨM ==========")
print(segment_summary)

print("\nHOÀN THÀNH PHÂN TÍCH PRODUCT")

