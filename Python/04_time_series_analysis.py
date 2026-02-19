
import pandas as pd
import matplotlib.pyplot as plt

# ======================================================
# ĐỌC DỮ LIỆU
# ======================================================

sales = pd.read_csv("gold.fact_sales.csv")

sales.columns = sales.columns.str.strip().str.lower()
sales["order_date"] = pd.to_datetime(sales["order_date"])

# ======================================================
# DOANH THU THEO THÁNG
# ======================================================

monthly_revenue = sales.resample(
    "ME", on="order_date"
)["sales_amount"].sum()

print("========== DOANH THU THEO THÁNG ==========")
print(monthly_revenue)

# ======================================================
# TĂNG TRƯỞNG THEO THÁNG (MoM)
# ======================================================

mom_growth = monthly_revenue.pct_change() * 100

print("\n========== TĂNG TRƯỞNG MoM (%) ==========")
print(mom_growth)

# ======================================================
# MOVING AVERAGE 3 THÁNG
# ======================================================

moving_avg = monthly_revenue.rolling(3).mean()

# ======================================================
# THÁNG TỐT NHẤT & TỆ NHẤT
# ======================================================

print("\n========== HIỆU SUẤT ==========")
print("Tháng tốt nhất:", monthly_revenue.idxmax())
print("Tháng tệ nhất:", monthly_revenue.idxmin())

# ======================================================
# VẼ BIỂU ĐỒ XU HƯỚNG DOANH THU
# ======================================================

plt.figure(figsize=(12,6))

plt.plot(monthly_revenue, label="Doanh thu")
plt.plot(moving_avg, label="Moving Average 3 tháng")

plt.title("Xu hướng doanh thu theo thời gian")
plt.xlabel("Thời gian")
plt.ylabel("Doanh thu")
plt.legend()

plt.tight_layout()
plt.savefig("../images/revenue_trend.png")
plt.show()

# ======================================================
# SEASONALITY – DOANH THU THEO THÁNG TRONG NĂM
# ======================================================

sales["month"] = sales["order_date"].dt.month

seasonality = sales.groupby("month")["sales_amount"].sum()

plt.figure(figsize=(10,5))
seasonality.plot(kind="bar")

plt.title("TÍNH MÙA VỤ THEO THÁNG")
plt.xlabel("Tháng")
plt.ylabel("Doanh thu")

plt.tight_layout()
plt.savefig("../images/seasonality.png")
plt.show()

print("\nHOÀN THÀNH PHÂN TÍCH TIME SERIES")
