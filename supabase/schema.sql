-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE subscription_status AS ENUM ('free', 'weekly', 'monthly', 'yearly');
CREATE TYPE admin_role AS ENUM ('super_admin', 'content_manager', 'user_manager');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    display_name VARCHAR(100) NOT NULL DEFAULT 'مستخدم جديد',
    status subscription_status NOT NULL DEFAULT 'free',
    subscription_expiry TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    downloaded_tracks TEXT[] DEFAULT '{}',
    total_downloads INTEGER DEFAULT 0
);

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    description TEXT,
    description_ar TEXT,
    image_url TEXT,
    is_locked BOOLEAN DEFAULT FALSE,
    required_subscription subscription_status DEFAULT 'free',
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tracks table
CREATE TABLE tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    title_ar VARCHAR(200) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    artist_ar VARCHAR(100) NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    audio_url TEXT NOT NULL,
    image_url TEXT,
    duration INTEGER DEFAULT 0, -- in seconds
    is_locked BOOLEAN DEFAULT FALSE,
    required_subscription subscription_status DEFAULT 'free',
    download_count INTEGER DEFAULT 0,
    play_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admins table
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    role admin_role DEFAULT 'content_manager',
    permissions TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- App settings table
CREATE TABLE app_settings (
    key VARCHAR(50) PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_subscription_expiry ON users(subscription_expiry);

CREATE INDEX idx_categories_active_order ON categories(is_active, order_index);
CREATE INDEX idx_categories_subscription ON categories(required_subscription);

CREATE INDEX idx_tracks_category ON tracks(category_id);
CREATE INDEX idx_tracks_active_order ON tracks(is_active, order_index);
CREATE INDEX idx_tracks_subscription ON tracks(required_subscription);

CREATE INDEX idx_admins_email ON admins(email);
CREATE INDEX idx_admins_active ON admins(is_active);

-- Create functions for incrementing counters
CREATE OR REPLACE FUNCTION increment_play_count(track_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE tracks 
    SET play_count = play_count + 1 
    WHERE id = track_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_download_count(track_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE tracks 
    SET download_count = download_count + 1 
    WHERE id = track_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update last_active timestamp
CREATE OR REPLACE FUNCTION update_last_active()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_active = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update last_active on user updates
CREATE TRIGGER trigger_update_last_active
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_last_active();

-- Function to clean up expired subscriptions
CREATE OR REPLACE FUNCTION cleanup_expired_subscriptions()
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET status = 'free', subscription_expiry = NULL
    WHERE subscription_expiry < NOW() AND status != 'free';
END;
$$ LANGUAGE plpgsql;

-- Insert default app settings
INSERT INTO app_settings (key, value) VALUES 
('general', '{
    "app_name": "Music Player",
    "app_name_ar": "مشغل الموسيقى",
    "whatsapp_number": "+966501234567",
    "support_message": "Hello, I want to inquire about subscription plans",
    "support_message_ar": "مرحباً، أريد الاستفسار عن خطط الاشتراك",
    "app_version": "1.0.0",
    "force_update": false,
    "maintenance_mode": false
}');

-- Insert sample admin user (you should change this)
INSERT INTO admins (id, email, display_name, role, is_active) VALUES 
('00000000-0000-0000-0000-000000000001', 'admin@musicplayer.com', 'Super Admin', 'super_admin', true);

-- Insert sample categories
INSERT INTO categories (name, name_ar, description, description_ar, order_index) VALUES 
('Relaxing', 'موسيقى هادئة', 'Calm and peaceful music', 'موسيقى هادئة ومريحة', 1),
('Energetic', 'موسيقى حماسية', 'Upbeat and energetic music', 'موسيقى حماسية ونشطة', 2),
('Classical', 'موسيقى كلاسيكية', 'Classical music collection', 'مجموعة الموسيقى الكلاسيكية', 3),
('Premium', 'المحتوى المميز', 'Premium content for subscribers', 'محتوى مميز للمشتركين', 4);

-- Update premium category to require subscription
UPDATE categories 
SET is_locked = true, required_subscription = 'monthly' 
WHERE name = 'Premium';

-- Row Level Security (RLS) policies

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- Users can only see and modify their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Categories are readable by all authenticated users
CREATE POLICY "Categories are viewable by authenticated users" ON categories
    FOR SELECT USING (auth.role() = 'authenticated');

-- Only admins can modify categories
CREATE POLICY "Only admins can modify categories" ON categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

-- Tracks are readable by all authenticated users
CREATE POLICY "Tracks are viewable by authenticated users" ON tracks
    FOR SELECT USING (auth.role() = 'authenticated');

-- Only admins can modify tracks
CREATE POLICY "Only admins can modify tracks" ON tracks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

-- Only admins can access admin table
CREATE POLICY "Only admins can access admin data" ON admins
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );

-- App settings are readable by authenticated users, writable by admins
CREATE POLICY "App settings are viewable by authenticated users" ON app_settings
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can modify app settings" ON app_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE id = auth.uid() AND is_active = true
        )
    );
