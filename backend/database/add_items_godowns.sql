-- Create items table
CREATE TABLE IF NOT EXISTS items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT UNSIGNED NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_code VARCHAR(255) UNIQUE NOT NULL,
    selling_price DECIMAL(10,2) DEFAULT 0,
    purchase_price DECIMAL(10,2) DEFAULT 0,
    mrp DECIMAL(10,2) DEFAULT 0,
    stock_qty INT DEFAULT 0,
    unit VARCHAR(255) DEFAULT 'PCS',
    low_stock_alert INT DEFAULT 10,
    category VARCHAR(255),
    description TEXT,
    hsn_code VARCHAR(255),
    gst_rate DECIMAL(5,2) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
    INDEX idx_items_organization_id (organization_id),
    INDEX idx_items_item_code (item_code),
    INDEX idx_items_category (category),
    INDEX idx_items_is_active (is_active)
);

-- Create godowns table
CREATE TABLE IF NOT EXISTS godowns (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(255) UNIQUE NOT NULL,
    address TEXT,
    contact_person VARCHAR(255),
    phone VARCHAR(255),
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
    INDEX idx_godowns_organization_id (organization_id),
    INDEX idx_godowns_code (code),
    INDEX idx_godowns_is_active (is_active)
);

-- Create item_godown_stock table
CREATE TABLE IF NOT EXISTS item_godown_stock (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT UNSIGNED NOT NULL,
    godown_id BIGINT UNSIGNED NOT NULL,
    quantity INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (godown_id) REFERENCES godowns(id) ON DELETE CASCADE,
    UNIQUE KEY unique_item_godown (item_id, godown_id),
    INDEX idx_item_godown_stock_item_id (item_id),
    INDEX idx_item_godown_stock_godown_id (godown_id)
);
