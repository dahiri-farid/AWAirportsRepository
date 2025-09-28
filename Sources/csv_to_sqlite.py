#!/usr/bin/env python3
"""
CSV to SQLite Database Converter for OurAirports Data

This script converts the OurAirports CSV files into a well-structured SQLite database
with proper relationships and data types.
"""

import sqlite3
import csv
import os
import sys
from pathlib import Path


def create_database_schema(cursor):
    """Create the database schema with proper relationships."""
    
    # Countries table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS countries (
            id INTEGER PRIMARY KEY,
            code TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            continent TEXT,
            wikipedia_link TEXT,
            keywords TEXT
        )
    """)
    
    # Regions table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS regions (
            id INTEGER PRIMARY KEY,
            code TEXT UNIQUE NOT NULL,
            local_code TEXT,
            name TEXT NOT NULL,
            continent TEXT,
            iso_country TEXT,
            wikipedia_link TEXT,
            keywords TEXT,
            FOREIGN KEY (iso_country) REFERENCES countries(code)
        )
    """)
    
    # Airports table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS airports (
            id INTEGER PRIMARY KEY,
            ident TEXT UNIQUE NOT NULL,
            type TEXT,
            name TEXT,
            latitude_deg REAL,
            longitude_deg REAL,
            elevation_ft INTEGER,
            continent TEXT,
            iso_country TEXT,
            iso_region TEXT,
            municipality TEXT,
            scheduled_service TEXT,
            icao_code TEXT,
            iata_code TEXT,
            gps_code TEXT,
            local_code TEXT,
            home_link TEXT,
            wikipedia_link TEXT,
            keywords TEXT,
            FOREIGN KEY (iso_country) REFERENCES countries(code),
            FOREIGN KEY (iso_region) REFERENCES regions(code)
        )
    """)
    
    # Airport frequencies table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS airport_frequencies (
            id INTEGER PRIMARY KEY,
            airport_ref INTEGER,
            airport_ident TEXT,
            type TEXT,
            description TEXT,
            frequency_mhz REAL,
            FOREIGN KEY (airport_ref) REFERENCES airports(id),
            FOREIGN KEY (airport_ident) REFERENCES airports(ident)
        )
    """)
    
    # Runways table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS runways (
            id INTEGER PRIMARY KEY,
            airport_ref INTEGER,
            airport_ident TEXT,
            length_ft INTEGER,
            width_ft INTEGER,
            surface TEXT,
            lighted INTEGER,
            closed INTEGER,
            le_ident TEXT,
            le_latitude_deg REAL,
            le_longitude_deg REAL,
            le_elevation_ft INTEGER,
            le_heading_degT REAL,
            le_displaced_threshold_ft INTEGER,
            he_ident TEXT,
            he_latitude_deg REAL,
            he_longitude_deg REAL,
            he_elevation_ft INTEGER,
            he_heading_degT REAL,
            he_displaced_threshold_ft INTEGER,
            FOREIGN KEY (airport_ref) REFERENCES airports(id),
            FOREIGN KEY (airport_ident) REFERENCES airports(ident)
        )
    """)
    
    # Navaids table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS navaids (
            id INTEGER PRIMARY KEY,
            filename TEXT,
            ident TEXT,
            name TEXT,
            type TEXT,
            frequency_khz INTEGER,
            latitude_deg REAL,
            longitude_deg REAL,
            elevation_ft INTEGER,
            iso_country TEXT,
            dme_frequency_khz INTEGER,
            dme_channel TEXT,
            dme_latitude_deg REAL,
            dme_longitude_deg REAL,
            dme_elevation_ft INTEGER,
            slaved_variation_deg REAL,
            magnetic_variation_deg REAL,
            usage_type TEXT,
            power TEXT,
            associated_airport TEXT,
            FOREIGN KEY (iso_country) REFERENCES countries(code),
            FOREIGN KEY (associated_airport) REFERENCES airports(ident)
        )
    """)
    
    # Airport comments table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS airport_comments (
            id INTEGER PRIMARY KEY,
            thread_ref INTEGER,
            airport_ref INTEGER,
            airport_ident TEXT,
            date TEXT,
            member_nickname TEXT,
            subject TEXT,
            body TEXT,
            FOREIGN KEY (airport_ref) REFERENCES airports(id),
            FOREIGN KEY (airport_ident) REFERENCES airports(ident)
        )
    """)
    
    # Create indexes for better performance
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_airports_country ON airports(iso_country)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_airports_region ON airports(iso_region)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_airports_ident ON airports(ident)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_airports_iata ON airports(iata_code)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_airports_icao ON airports(icao_code)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_frequencies_airport ON airport_frequencies(airport_ref)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_runways_airport ON runways(airport_ref)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_navaids_country ON navaids(iso_country)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_comments_airport ON airport_comments(airport_ref)")


def safe_int(value):
    """Safely convert value to integer, return None if invalid."""
    if value == '' or value is None:
        return None
    try:
        return int(value)
    except (ValueError, TypeError):
        return None


def safe_float(value):
    """Safely convert value to float, return None if invalid."""
    if value == '' or value is None:
        return None
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def safe_bool(value):
    """Safely convert value to boolean (0/1), return None if invalid."""
    if value == '' or value is None:
        return None
    if isinstance(value, str):
        value = value.lower()
        if value in ['yes', 'true', '1']:
            return 1
        elif value in ['no', 'false', '0']:
            return 0
    try:
        return int(value)
    except (ValueError, TypeError):
        return None


def import_csv_file(cursor, csv_file, table_name, columns_mapping=None):
    """Import a CSV file into the database."""
    print(f"Importing {csv_file}...")
    
    if not os.path.exists(csv_file):
        print(f"Warning: {csv_file} not found, skipping...")
        return
    
    with open(csv_file, 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row_num, row in enumerate(reader, 1):
            # Skip empty rows
            if not any(row.values()):
                continue
                
            # Clean the data
            cleaned_row = {}
            for key, value in row.items():
                # Remove quotes and strip whitespace
                if isinstance(value, str):
                    value = value.strip().strip('"')
                    if value == '':
                        value = None
                
                # Apply column mapping if provided
                if columns_mapping and key in columns_mapping:
                    cleaned_row[columns_mapping[key]] = value
                else:
                    cleaned_row[key] = value
            
            # Prepare the SQL insert statement
            columns = list(cleaned_row.keys())
            placeholders = ', '.join(['?' for _ in columns])
            values = list(cleaned_row.values())
            
            sql = f"INSERT OR REPLACE INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
            
            try:
                cursor.execute(sql, values)
            except sqlite3.Error as e:
                print(f"Error inserting row {row_num} from {csv_file}: {e}")
                print(f"Row data: {cleaned_row}")
                continue
    
    print(f"Successfully imported {csv_file}")


def main():
    """Main function to convert CSV files to SQLite database."""
    
    # Get the directory where the script is located
    script_dir = Path(__file__).parent
    db_path = script_dir / "ourairports.db"
    
    # Remove existing database if it exists
    if db_path.exists():
        print(f"Removing existing database: {db_path}")
        db_path.unlink()
    
    # Create connection to SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Create the database schema
        print("Creating database schema...")
        create_database_schema(cursor)
        
        # Define column mappings for tables that need them
        columns_mappings = {
            'airport-frequencies.csv': {
                'airport_ref': 'airport_ref',
                'airport_ident': 'airport_ident'
            },
            'airport-comments.csv': {
                ' "threadRef"': 'thread_ref',
                ' "airportRef"': 'airport_ref',
                ' "airportIdent"': 'airport_ident',
                ' "memberNickname"': 'member_nickname'
            },
            'runways.csv': {
                'airport_ref': 'airport_ref',
                'airport_ident': 'airport_ident'
            },
            'navaids.csv': {
                'usageType': 'usage_type',
                'associated_airport': 'associated_airport'
            }
        }
        
        # Import CSV files in order (respecting foreign key constraints)
        csv_files = [
            ('countries.csv', 'countries'),
            ('regions.csv', 'regions'),
            ('airports.csv', 'airports'),
            ('airport-frequencies.csv', 'airport_frequencies'),
            ('runways.csv', 'runways'),
            ('navaids.csv', 'navaids'),
            ('airport-comments.csv', 'airport_comments')
        ]
        
        for csv_file, table_name in csv_files:
            csv_path = script_dir / csv_file
            columns_mapping = columns_mappings.get(csv_file)
            import_csv_file(cursor, csv_path, table_name, columns_mapping)
        
        # Commit all changes
        conn.commit()
        
        # Display summary statistics
        print("\n" + "="*50)
        print("DATABASE CONVERSION SUMMARY")
        print("="*50)
        
        tables = ['countries', 'regions', 'airports', 'airport_frequencies', 
                 'runways', 'navaids', 'airport_comments']
        
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            count = cursor.fetchone()[0]
            print(f"{table:20}: {count:,} records")
        
        print(f"\nDatabase created successfully: {db_path}")
        print(f"Database size: {db_path.stat().st_size / (1024*1024):.2f} MB")
        
    except Exception as e:
        print(f"Error during conversion: {e}")
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
