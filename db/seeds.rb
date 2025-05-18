# Limpiar la base de datos antes de sembrar nuevos datos
puts "Limpiando la base de datos..."
Purchase.destroy_all
Attachment.destroy_all
CategoriesProduct.destroy_all
Category.destroy_all
DigitalProduct.destroy_all
PhysicalProduct.destroy_all
Product.destroy_all
User.destroy_all

# Administradores (5)
puts "Creando usuarios..."

admins = [
  { name: "Admin Principal", email: "admin@example.com", password: "password", role: :admin },
  { name: "Maria Rodríguez", email: "maria@example.com", password: "password", role: :admin },
  { name: "Juan Pérez", email: "juan@example.com", password: "password", role: :admin },
  { name: "Ana López", email: "ana@example.com", password: "password", role: :admin },
  { name: "Carlos Sánchez", email: "carlos@example.com", password: "password", role: :admin }
]

admin_users = admins.map do |admin_data|
  User.create!(admin_data)
end

# Clientes (15)
clients = [
  { name: "Cliente Uno", email: "cliente1@example.com", password: "password", role: :client },
  { name: "Cliente Dos", email: "cliente2@example.com", password: "password", role: :client },
  { name: "Cliente Tres", email: "cliente3@example.com", password: "password", role: :client },
  { name: "Cliente Cuatro", email: "cliente4@example.com", password: "password", role: :client },
  { name: "Cliente Cinco", email: "cliente5@example.com", password: "password", role: :client },
  { name: "Cliente Seis", email: "cliente6@example.com", password: "password", role: :client },
  { name: "Cliente Siete", email: "cliente7@example.com", password: "password", role: :client },
  { name: "Cliente Ocho", email: "cliente8@example.com", password: "password", role: :client },
  { name: "Cliente Nueve", email: "cliente9@example.com", password: "password", role: :client },
  { name: "Cliente Diez", email: "cliente10@example.com", password: "password", role: :client },
  { name: "Cliente Once", email: "cliente11@example.com", password: "password", role: :client },
  { name: "Cliente Doce", email: "cliente12@example.com", password: "password", role: :client },
  { name: "Cliente Trece", email: "cliente13@example.com", password: "password", role: :client },
  { name: "Cliente Catorce", email: "cliente14@example.com", password: "password", role: :client },
  { name: "Cliente Quince", email: "cliente15@example.com", password: "password", role: :client }
]

client_users = clients.map do |client_data|
  User.create!(client_data)
end

puts "Creados #{User.count} usuarios"

# Crear categorías
puts "Creando categorías..."
categories_data = [
  # Categorías para productos digitales
  { name: "Software", description: "Programas, aplicaciones y licencias", creator: admin_users.sample },
  { name: "Libros Digitales", description: "E-books y publicaciones digitales", creator: admin_users.sample },
  { name: "Cursos", description: "Cursos y material educativo digital", creator: admin_users.sample },
  { name: "Música", description: "Álbumes y canciones digitales", creator: admin_users.sample },
  { name: "Películas", description: "Películas y series digitales", creator: admin_users.sample },
  { name: "Electrónicos", description: "Productos electrónicos y gadgets", creator: admin_users.sample },
  { name: "Computadoras", description: "Laptops, desktops y accesorios", creator: admin_users.sample },
  { name: "Smartphones", description: "Teléfonos móviles y accesorios", creator: admin_users.sample },
  { name: "Audio", description: "Auriculares, altavoces y equipos de sonido", creator: admin_users.sample },
  { name: "Videojuegos", description: "Consolas, juegos y accesorios", creator: admin_users.sample },
  { name: "Ropa", description: "Prendas de vestir y accesorios", creator: admin_users.sample },
  { name: "Calzado", description: "Zapatos, zapatillas y botas", creator: admin_users.sample },
  { name: "Hogar", description: "Artículos para el hogar y decoración", creator: admin_users.sample },
  { name: "Cocina", description: "Utensilios y electrodomésticos de cocina", creator: admin_users.sample },
  { name: "Deportes", description: "Equipamiento y ropa deportiva", creator: admin_users.sample },
  { name: "Juguetes", description: "Juguetes y juegos para niños", creator: admin_users.sample },
  { name: "Belleza", description: "Productos de belleza y cuidado personal", creator: admin_users.sample },
  { name: "Salud", description: "Productos para la salud y bienestar", creator: admin_users.sample },
  { name: "Mascotas", description: "Productos para mascotas", creator: admin_users.sample },
  { name: "Jardín", description: "Herramientas y productos para jardinería", creator: admin_users.sample }
]

categories = categories_data.map do |category_data|
  Category.create!(category_data)
end

puts "Creadas #{Category.count} categorías"

# Crear productos digitales
puts "Creando productos digitales..."
digital_products_data = [
  {
    name: "Curso de Programación en Python",
    description: "Aprende Python desde cero hasta un nivel avanzado",
    price: "49.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/python-course",
    file_size: 1500, # MB
    file_format: "ZIP"
  },
  {
    name: "E-book: Guía de Desarrollo Web",
    description: "Todo lo que necesitas saber sobre desarrollo web moderno",
    price: "19.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/web-dev-guide",
    file_size: 15, # MB
    file_format: "PDF"
  },
  {
    name: "Software de Edición de Fotos",
    description: "Herramienta profesional para edición de imágenes",
    price: "79.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/photo-editor",
    file_size: 500, # MB
    file_format: "EXE"
  },
  {
    name: "Álbum Musical: Éxitos 2023",
    description: "Colección de los mejores temas del año",
    price: "9.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/hits-2023",
    file_size: 320, # MB
    file_format: "MP3"
  },
  {
    name: "Película: Aventuras en el Espacio",
    description: "Emocionante película de ciencia ficción",
    price: "14.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/space-adventures",
    file_size: 4500, # MB
    file_format: "MP4"
  }
]

digital_products = []

digital_products_data.each do |product_data|
  selected_categories = categories.select { |c| [ 1, 2, 3, 4, 5 ].include?(c.id) }.sample(rand(1..3))
  product = DigitalProduct.create!(product_data)
  selected_categories.each do |category|
    CategoriesProduct.create!(category: category, product: product)
  end

  digital_products << product
end

puts "Creados #{DigitalProduct.count} productos digitales"

# Crear productos físicos
puts "Creando productos físicos..."
physical_products_data = [
  {
    name: "Smartphone Galaxy X10",
    description: "Teléfono inteligente de última generación",
    price: "699.99",
    stock: 50,
    creator: admin_users.sample,
    weight: 0.2, # kg
    dimensions: "15x7x0.8" # cm
  },
  {
    name: "Laptop UltraBook Pro",
    description: "Portátil potente y ligero para profesionales",
    price: "1299.99",
    stock: 25,
    creator: admin_users.sample,
    weight: 1.5, # kg
    dimensions: "35x25x1.5" # cm
  },
  {
    name: "Auriculares Noise Cancel",
    description: "Auriculares con cancelación de ruido",
    price: "199.99",
    stock: 100,
    creator: admin_users.sample,
    weight: 0.3, # kg
    dimensions: "18x18x8" # cm
  },
  {
    name: "Zapatillas Running Pro",
    description: "Zapatillas para corredores profesionales",
    price: "129.99",
    stock: 80,
    creator: admin_users.sample,
    weight: 0.4, # kg
    dimensions: "30x20x15" # cm
  },
  {
    name: "Cámara DSLR 4K",
    description: "Cámara profesional de alta resolución",
    price: "899.99",
    stock: 30,
    creator: admin_users.sample,
    weight: 0.8, # kg
    dimensions: "15x10x8" # cm
  }
]

physical_products = []

physical_products_data.each do |product_data|
  selected_categories = categories.select { |c| [ 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ].include?(c.id) }.sample(rand(1..3))
  product = PhysicalProduct.create!(product_data)
  selected_categories.each do |category|
    CategoriesProduct.create!(category: category, product: product)
  end

  physical_products << product
end

puts "Creados #{PhysicalProduct.count} productos físicos"

# Crear compras
puts "Creando compras..."

def random_date
  rand(1..180).days.ago
end

# Crear compras para productos digitales
digital_products.each do |product|
  rand(1..5).times do
    client = client_users.sample

    Purchase.create!(
      client: client,
      product: product,
      quantity: 1,
      total_price: product.price,
      created_at: random_date,
      updated_at: random_date
    )
  end
end

# Crear compras para productos físicos
physical_products.each do |product|
  rand(0..5).times do
    client = client_users.sample
    quantity = rand(1..3)
    if product.stock >= quantity
      purchase_date = random_date

      Purchase.create!(
        client: client,
        product: product,
        quantity: quantity,
        total_price: (product.price.to_f * quantity).to_s,
        created_at: purchase_date,
        updated_at: purchase_date
      )

      product.update!(stock: product.stock - quantity)
    end
  end
end

puts "Creadas #{Purchase.count} compras"

# Crear attachments (imágenes) para productos
puts "Creando attachments para productos..."

def create_attachment_for(product)
  attachment = Attachment.create!(record: product)
  attachment
end

# Crear attachments para productos digitales
digital_products.each do |product|
  rand(1..2).times do
    create_attachment_for(product)
  end
end

# Crear attachments para productos físicos
physical_products.each do |product|
  rand(1..4).times do
    create_attachment_for(product)
  end
end

puts "Creados #{Attachment.count} attachments"

puts "Proceso de seed completado exitosamente!"
puts "Resumen:"
puts "- #{User.count} usuarios (#{User.where(role: :admin).count} administradores, #{User.where(role: :client).count} clientes)"
puts "- #{Category.count} categorías"
puts "- #{Product.count} productos (#{DigitalProduct.count} digitales, #{PhysicalProduct.count} físicos)"
puts "- #{Purchase.count} compras"
puts "- #{Attachment.count} imágenes adjuntas"
