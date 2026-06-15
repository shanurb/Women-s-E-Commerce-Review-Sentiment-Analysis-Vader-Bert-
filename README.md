# Customer Sentiment & NLP System

> *Deciphering what customers mean — not just what they rate.*

An end-to-end NLP pipeline that analyses 22,000+ women's clothing reviews using dual sentiment models (VADER + DistilBERT), stores and queries data in PostgreSQL, and surfaces business insights through an interactive Power BI dashboard.

**Key finding:** 18.7% of highly-rated (4–5 star) products contained negative language in review text, a hidden dissatisfaction signal invisible to star-rating analysis alone.

---

## The problem

Star ratings lie.

A customer gives 4 stars but writes *"love the style but it runs two sizes small and the fabric feels cheap."* The business sees a happy customer. The NLP model sees a sizing complaint and a quality concern.

This project was built to close that gap to extract what customers *actually* feel from the words they use, not the number they click.

---

## Tech stack

| Layer | Tool |
|---|---|
| Data storage & querying | PostgreSQL |
| Data processing | Python, Pandas |
| NLP models | VADER, DistilBERT (HuggingFace Transformers) |
| Development environment | Jupyter Notebook (VS Code) |
| Visualisation | Power BI |
| Dataset | Women's Clothing E-Commerce Reviews (Kaggle) |

---

## Pipeline overview

```
Raw CSV (Kaggle)
      │
      ▼
PostgreSQL ──── SQL views & analytical queries
      │
      ▼
Python / Jupyter
  ├── Text cleaning & preprocessing
  ├── VADER sentiment scoring (rule-based)
  ├── DistilBERT sentiment scoring (transformer)
  ├── Topic tagging (sizing, fabric, delivery, etc.)
  └── Hidden dissatisfaction flagging
      │
      ▼
Results written back to PostgreSQL
      │
      ▼
CSV export ──── Power BI Dashboard (3 pages)
```

---

## Project structure

```
clothing_sentiment/
│
├── data/
│   ├── womens_clothing_reviews.csv       # raw dataset
│   ├── reviews_clean.csv                 # after cleaning
│   ├── sentiment_results.csv             # scored output
│   ├── topic_summary.csv                 # aggregated by topic
│   ├── hidden_dissatisfaction.csv        # mismatch analysis
│   ├── dept_summary.csv                  # by department
│   └── age_summary.csv                   # by age group
│
├── notebooks/
│   └── sentiment_analysis.ipynb          # full pipeline notebook
│
├── sql/
│   └── setup.sql                         # table creation + views
│
├── .env.example                          # env variable template
├── requirements.txt
└── README.md
```

---

## Quickstart

**1. Clone the repo**
```bash
git clone https://github.com/yourusername/clothing-sentiment-nlp.git
cd clothing-sentiment-nlp
```

**2. Create and activate virtual environment**
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Mac / Linux
source venv/bin/activate
```

**3. Install dependencies**
```bash
pip install -r requirements.txt
```

**4. Set up environment variables**
```bash
cp .env.example .env
# Fill in your PostgreSQL credentials in .env
```

**5. Set up PostgreSQL**

Run `sql/setup.sql` in pgAdmin or psql to create the database, tables, and views.

Then load the dataset:
```sql
COPY reviews_raw (clothing_id, age, review_title, review_text, rating,
                  recommended, positive_feedback, division_name,
                  department_name, class_name)
FROM '/your/path/to/womens_clothing_reviews.csv'
DELIMITER ',' CSV HEADER;
```

**6. Run the notebook**

Open `notebooks/sentiment_analysis.ipynb` in VS Code and run all cells top to bottom.

**7. Load into Power BI**

Import the CSV files from `/data/` into Power BI and follow the dashboard layout described below.

---

## How the models work

### VADER (Valence Aware Dictionary and sEntiment Reasoner)
Rule-based model optimised for social and review text. Fast, interpretable, no training required. Compound score ranges from -1 (most negative) to +1 (most positive).

```python
score = analyzer.polarity_scores(text)['compound']
# >= 0.05  → positive
# <= -0.05 → negative
# between  → neutral
```

### DistilBERT
A lightweight version of BERT fine-tuned on SST-2 (Stanford Sentiment Treebank). Understands context and nuance that rule-based models miss — sarcasm, hedging, mixed sentiment within a single sentence.

```python
model = "distilbert-base-uncased-finetuned-sst-2-english"
```

Both models run on every review. Where they disagree, DistilBERT is used as the primary label (more context-aware), but the disagreement itself is flagged as a signal worth investigating.

---

## Topic tagging

Every review is tagged with a business topic based on keyword matching:

| Topic | Keywords (sample) |
|---|---|
| Sizing & fit | size, sizing, fit, tight, loose, runs, petite |
| Fabric & quality | fabric, material, quality, thin, stitching, cheap |
| Style & look | style, cute, beautiful, flattering, design, color |
| Comfort | comfortable, itchy, cozy, warm, breathable |
| Price & value | expensive, overpriced, worth, value, affordable |
| Delivery & packaging | shipping, delivery, arrived, late, damaged |
| Customer service | return, refund, exchange, support, helpful |

---

## Key findings

### Hidden dissatisfaction
**18.7% of 4–5 star reviews contained negative language** when analysed by DistilBERT.

Of those:

| Topic | Share of hidden complaints |
|---|---|
| Sizing & fit | 74% |
| Fabric & quality | 42% |
| Delivery | 31% |
| Price & value | 18% |
| Customer service | 12% |

### Age group insight
Customers over 46 leave more positive reviews overall — younger customers (under 30) are significantly more critical about sizing in particular.

### Model agreement
VADER and DistilBERT agree on **~81%** of reviews. The 19% disagreement rate is concentrated in 3-star reviews and reviews with mixed sentiment — exactly where nuance matters most.

---

## Power BI dashboard

Three-page dashboard built on the exported CSVs:

**Page 1 — Overview**
KPI cards (total reviews, % positive, % negative, % hidden dissatisfaction) · Sentiment donut chart · Negative % by topic bar chart · Monthly sentiment trend line

**Page 2 — Deep dive**
Star rating vs BERT sentiment comparison · Sentiment by age group · Topic × sentiment matrix with conditional formatting · Slicers for department, rating, age group

**Page 3 — So what**
Headline insight card · Hidden dissatisfaction breakdown by topic · Key finding summary · Business recommendation

---

## Business recommendation

> Sizing and fit is the single biggest driver of hidden dissatisfaction — accounting for 74% of negative language in otherwise high-rated reviews.
>
> Style and fabric quality scores are strong. The product is not the problem. Customers cannot confidently predict how a garment will fit before buying.
>
> **Recommended actions:**
> - Introduce detailed size guides with real customer measurements per product
> - Add a "does this run true to size?" poll on product pages
> - Flag high-dissatisfaction size ranges for quality review
>
> Fixing size confidence is expected to reduce return rates and convert hesitant browsers into buyers.

---

## Requirements

```
pandas
psycopg2-binary
sqlalchemy
python-dotenv
vaderSentiment
transformers
torch
scikit-learn
matplotlib
seaborn
ipykernel
```

Install all with:
```bash
pip install -r requirements.txt
```

---

## Dataset

**Women's Clothing E-Commerce Reviews** — publicly available on [Kaggle](https://www.kaggle.com/datasets/nicapotato/womens-ecommerce-clothing-reviews).

22,641 reviews with rating, review text, department, clothing category, age, and recommendation flag. No personal identifiers.

---

## Author

**Uswah Riaz** — CS educator turned data analyst.
Passionate about extracting business value from messy, unstructured data.
