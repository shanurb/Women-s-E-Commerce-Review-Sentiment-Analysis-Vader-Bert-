# Customer Sentiment and NLP System

> *Deciphering what customers mean, not just what they rate.*

An end-to-end NLP pipeline that analyses 22,000+ women's clothing reviews using dual sentiment models (VADER + DistilBERT), stores and queries data in PostgreSQL, and surfaces business insights through an interactive Power BI dashboard.

**Key finding:** 14.41% of total reviews contain hidden dissatisfaction where customers give highly-rated (4–5 star) reviews but express negative sentiment in their actual review text.

---

## The problem

Star ratings lie.

A customer clicks 4 stars but writes *"love the style but it runs two sizes small and the fabric feels cheap."* The business sees a happy customer. The NLP model sees a sizing complaint and a quality concern.

This project closes that gap by extracting what customers *actually* feel from the words they use, not just the number they click.

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
Raw CSV (Kaggle)│▼PostgreSQL ──── SQL views & analytical queries│▼Python / Jupyter├── Text cleaning & preprocessing├── VADER sentiment scoring (rule-based)├── DistilBERT sentiment scoring (transformer)├── Multi-label topic tagging (one-hot encoding)└── Hidden dissatisfaction flagging│▼Results written back to PostgreSQL│▼Clean Views ──── Power BI Dashboard (3 pages)
---

## Project structure clothing_sentiment/│├── data/│   ├── womens_clothing_reviews.csv       # raw dataset│   └── sentiment_results.csv             # scored output matrix│├── notebooks/│   └── sentiment_analysis.ipynb          # full pipeline notebook│├── sql/│   └── setup.sql                         # table creation + analytical views│├── .env.example                          # env variable template├── requirements.txt└── README.md
---

## Quickstart

**1. Clone the repo**
```bash
git clone https://github.com
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

Run `sql/setup.sql` in pgAdmin or psql to initialize the schemas and optimized aggregation views.

Then load the raw dataset:
```sql
COPY reviews_raw (clothing_id, age, review_title, review_text, rating,
                  recommended, positive_feedback, division_name,
                  department_name, class_name)
FROM '/your/path/to/womens_clothing_reviews.csv'
DELIMITER ',' CSV HEADER;
```

**6. Run the notebook**

Open `notebooks/sentiment_analysis.ipynb` in VS Code and run all cells top to bottom to execute the models.

**7. Open the Power BI Dashboard**

Connect your Power BI Desktop client directly to your PostgreSQL database instances or import the analytical view exports to view the interactive dashboard templates.

---

## How the models work

### VADER (Valence Aware Dictionary and sEntimer Reasoner)
Rule-based model optimized for social and review text. Fast, interpretable, and highly effective for standard sentiment checks. Compound score ranges from -1 (most negative) to +1 (most positive).

```python
score = analyzer.polarity_scores(text)['compound']
# >= 0.05  → positive
# <= -0.05 → negative
# between  → neutral
```

### DistilBERT
A lightweight, high-performance transformer model fine-tuned on SST-2 (Stanford Sentiment Treebank). Understands context and structural nuance that rule-based dictionary models miss such as sarcasm, hedging, and mixed sentiment within a single text block.

```python
model = "distilbert-base-uncased-finetuned-sst-2-english"
```

Both models execute across every review row. To handle multi-topic records cleanly without inflating row counts in Power BI, topics are tracked using explicit binary flags (One-Hot Encoding matrix columns).

---

## Topic tagging matrix

Reviews are parsed and categorized across target operations using regex keyword matching:

| Topic | Keywords (sample) |
|---|---|
| Sizing & fit | size, sizing, fit, tight, loose, runs, petite, small |
| Fabric & quality | fabric, material, quality, thin, stitching, cheap |
| Style & look | style, cute, beautiful, flattering, design, color |
| Comfort | comfortable, itchy, cozy, warm, breathable |
| Price & value | expensive, overpriced, worth, value, affordable |
| Delivery & packaging | shipping, delivery, arrived, late, damaged |
| Customer service | return, refund, exchange, support, helpful |

---

## Key findings

### Global distribution metrics
The total processed review footprint contains **22,587 valid customer records**:
*   **Total Positive Sentiment**: 67.59% (15.27K reviews)
*   **Total Negative Sentiment**: 32.41% (7.32K reviews)

### Hidden dissatisfaction anomalies
Among highly-rated items (4–5 stars), **14.41%** exhibited hidden complaints where actual review language was structurally negative. When unpacking this specific anomaly segment, topic distribution reveals clear targets:

| Target Operational Topic | Share of Dissatisfaction Subgroup |
|---|---|
| Sizing & fit | 74.0% |
| Fabric & quality | 42.0% |
| Delivery & packaging | 31.0% |
| Price & value | 18.0% |
| Customer service | 12.0% |

*Note: Percentages do not sum to 100% because individual reviews can contain multiple topic tags.*

---

## Power BI dashboard architecture

The project features an interactive, three-page dashboard built directly on PostgreSQL views:

*   **Page 1 — Overview**: Displays core KPI metrics like Total reviews, % Positive, % Negative, and % Hidden Dissatisfaction. Features an explicit sentiment donut chart mapping alongside a global negative frequency breakdown chart.
*   **Page 2 — Deep Dive**: Cross-analyzes rating matrices, age bracket sentiment distributions, and a complete multi-topic sentiment matrix with conditional formatting toggles.
*   **Page 3 — Summary**: Highlights operational risk areas, presents specific subgroup findings, and summarizes strategic development recommendations.

---

## Strategic recommendations

> Sizing and fit inconsistencies represent the single largest driver of hidden customer dissatisfaction, appearing in 74% of negative text blocks in high-rated reviews.
> 
> Product design and fabric quality scores remain fundamentally strong across categories. The physical items are well-received, but customers struggle to predict proper garment fit before ordering.
> 
> **Recommended Actions:**
> *   Deploy interactive sizing calculators featuring real customer dimensions on high-volume item pages.
> *   Integrate community "True to Size" feedback voting gauges above purchasing selectors.
> *   Flag high-volume return items showing persistent size-tagging mismatches for quality control audits.

---

## Author

**Uswah Riaz** — CS educator turned data analyst.
Passionate about extracting business value from messy, unstructured data.
