-- Create parties table
CREATE TABLE IF NOT EXISTS parties (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    organization_id INTEGER NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20) NOT NULL,
    gst_no VARCHAR(50),
    billing_address TEXT,
    shipping_address TEXT,
    party_type VARCHAR(20) NOT NULL DEFAULT 'customer' CHECK(party_type IN ('customer', 'vendor', 'both')),
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_parties_organization_id ON parties(organization_id);
CREATE INDEX IF NOT EXISTS idx_parties_party_type ON parties(party_type);
CREATE INDEX IF NOT EXISTS idx_parties_is_active ON parties(is_active);
