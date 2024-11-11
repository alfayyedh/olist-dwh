#!/bin/bash

echo "========== Start Orcestration Process =========="

# Virtual Environment Path
VENV_PATH="/home/alfayyedh/pacmann/data-warehouse/dataset-olist/venv/bin/activate"

# Activate Virtual Environment
source "$VENV_PATH"

# Set Python script
PYTHON_SCRIPT="/home/alfayyedh/pacmann/data-warehouse/dataset-olist/main_elt_pipeline.py"

# Run Python Script 
python "$PYTHON_SCRIPT"

echo "========== End of Orcestration Process =========="