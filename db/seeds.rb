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
  { name: "Aplicaciones", description: "Aplicaciones móviles y software para smartphones", creator: admin_users.sample },

  # Categorías para productos físicos
  { name: "Electrónicos", description: "Productos electrónicos y gadgets", creator: admin_users.sample },
  { name: "Computadoras", description: "Laptops, desktops y accesorios", creator: admin_users.sample },
  { name: "Smartphones", description: "Teléfonos móviles y accesorios", creator: admin_users.sample },
  { name: "Audio", description: "Auriculares, altavoces y equipos de sonido", creator: admin_users.sample },
  { name: "Videojuegos", description: "Consolas, juegos y accesorios", creator: admin_users.sample },
  { name: "Fotografía", description: "Cámaras y accesorios fotográficos", creator: admin_users.sample },
  { name: "Ropa", description: "Prendas de vestir y accesorios", creator: admin_users.sample },
  { name: "Calzado", description: "Zapatos, zapatillas y botas", creator: admin_users.sample },
  { name: "Hogar", description: "Artículos para el hogar y decoración", creator: admin_users.sample },
  { name: "Cocina", description: "Utensilios y electrodomésticos de cocina", creator: admin_users.sample },
  { name: "Deportes", description: "Equipamiento y ropa deportiva", creator: admin_users.sample },
  { name: "Juguetes", description: "Juguetes y juegos para niños", creator: admin_users.sample },
  { name: "Belleza", description: "Productos de belleza y cuidado personal", creator: admin_users.sample },
  { name: "Salud", description: "Productos para la salud y bienestar", creator: admin_users.sample }
]

categories = categories_data.map do |category_data|
  Category.create!(category_data)
end

# Crear mapeo de categorías para referencia fácil
category_map = {}
categories.each do |category|
  category_map[category.name] = category
end

puts "Creadas #{Category.count} categorías"

# Crear productos digitales con categorías apropiadas
puts "Creando productos digitales..."
digital_products_data = [
  {
    name: "Curso de Programación en Python",
    description: "Aprende Python desde cero hasta un nivel avanzado con ejercicios prácticos y proyectos reales",
    price: "49.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/python-course",
    file_size: 1500, # MB
    file_format: "ZIP",
    categories: [ "Cursos", "Software" ]
  },
  {
    name: "Curso de Marketing Digital",
    description: "Domina las estrategias de marketing en línea, SEO, SEM y redes sociales",
    price: "59.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/marketing-digital",
    file_size: 2200, # MB
    file_format: "ZIP",
    categories: [ "Cursos" ]
  },
  {
    name: "E-book: Guía de Desarrollo Web",
    description: "Todo lo que necesitas saber sobre desarrollo web moderno: HTML5, CSS3, JavaScript y más",
    price: "19.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/web-dev-guide",
    file_size: 15, # MB
    file_format: "PDF",
    categories: [ "Libros Digitales", "Cursos" ]
  },
  {
    name: "E-book: El Arte de la Cocina Mediterránea",
    description: "Recetas tradicionales mediterráneas con un toque moderno",
    price: "12.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/cocina-mediterranea",
    file_size: 25, # MB
    file_format: "PDF",
    categories: [ "Libros Digitales" ]
  },
  {
    name: "Suite de Diseño Gráfico Professional",
    description: "Herramienta profesional completa para diseño gráfico, ilustración y maquetación",
    price: "99.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/design-suite",
    file_size: 3500, # MB
    file_format: "EXE",
    categories: [ "Software" ]
  },
  {
    name: "Software de Edición de Fotos",
    description: "Herramienta profesional para edición y retoque de imágenes con funciones avanzadas",
    price: "79.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/photo-editor",
    file_size: 500, # MB
    file_format: "EXE",
    categories: [ "Software" ]
  },
  {
    name: "Álbum Musical: Éxitos 2023",
    description: "Colección de los mejores temas del año en calidad de alta definición",
    price: "9.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/hits-2023",
    file_size: 320, # MB
    file_format: "MP3",
    categories: [ "Música" ]
  },
  {
    name: "Álbum: Clásicos del Jazz",
    description: "Compilación remasterizada de los grandes clásicos del jazz",
    price: "11.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/jazz-classics",
    file_size: 450, # MB
    file_format: "FLAC",
    categories: [ "Música" ]
  },
  {
    name: "Película: Aventuras en el Espacio",
    description: "Emocionante película de ciencia ficción con efectos visuales de última generación",
    price: "14.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/space-adventures",
    file_size: 4500, # MB
    file_format: "MP4",
    categories: [ "Películas" ]
  },
  {
    name: "Serie Completa: Misterios del Océano",
    description: "Documental premiado sobre la vida marina y los ecosistemas oceánicos",
    price: "24.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/ocean-mysteries",
    file_size: 12000, # MB
    file_format: "MKV",
    categories: [ "Películas" ]
  },
  {
    name: "Aplicación de Organización Personal",
    description: "Gestiona tu tiempo, tareas y proyectos de manera eficiente en cualquier dispositivo",
    price: "5.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/organizer-app",
    file_size: 85, # MB
    file_format: "APK",
    categories: [ "Aplicaciones", "Software" ]
  },
  {
    name: "App de Meditación y Mindfulness",
    description: "Mejora tu bienestar mental con guías de meditación y ejercicios de atención plena",
    price: "3.99",
    creator: admin_users.sample,
    download_url: "https://example.com/downloads/meditation-app",
    file_size: 120, # MB
    file_format: "APK",
    categories: [ "Aplicaciones", "Salud" ]
  }
]

digital_products = []

digital_products_data.each do |product_data|
  # Extraer y eliminar el array de categorías del hash
  category_names = product_data.delete(:categories)

  # Crear el producto
  product = DigitalProduct.create!(product_data)

  # Asignar las categorías adecuadas
  category_names.each do |category_name|
    if category_map[category_name]
      CategoriesProduct.create!(category: category_map[category_name], product: product)
    end
  end

  digital_products << product
end

puts "Creados #{DigitalProduct.count} productos digitales"

# Crear productos físicos con categorías apropiadas
puts "Creando productos físicos..."
physical_products_data = [
  {
    name: "Smartphone Galaxy S25",
    description: "Teléfono inteligente de última generación con pantalla AMOLED de 6.7 pulgadas y cámara de 108MP",
    price: "899.99",
    stock: 50,
    creator: admin_users.sample,
    weight: 0.18, # kg
    dimensions: "16x7.5x0.7", # cm
    categories: [ "Smartphones", "Electrónicos" ]
  },
  {
    name: "iPhone 16 Pro",
    description: "El último modelo de Apple con chip A18 y sistema de triple cámara avanzada",
    price: "1099.99",
    stock: 35,
    creator: admin_users.sample,
    weight: 0.21, # kg
    dimensions: "14.8x7.2x0.8", # cm
    categories: [ "Smartphones", "Electrónicos" ]
  },
  {
    name: "Laptop UltraBook Pro",
    description: "Portátil potente y ligero para profesionales con procesador i9 y 32GB de RAM",
    price: "1499.99",
    stock: 25,
    creator: admin_users.sample,
    weight: 1.5, # kg
    dimensions: "35x24x1.2", # cm
    categories: [ "Computadoras", "Electrónicos" ]
  },
  {
    name: "MacBook Air M3",
    description: "Ultraligero y potente con el nuevo chip M3 y pantalla Retina",
    price: "1299.99",
    stock: 30,
    creator: admin_users.sample,
    weight: 1.2, # kg
    dimensions: "32x22x0.9", # cm
    categories: [ "Computadoras", "Electrónicos" ]
  },
  {
    name: "Auriculares SoundPro Noise Cancel",
    description: "Auriculares premium con cancelación de ruido activa y 30 horas de batería",
    price: "249.99",
    stock: 100,
    creator: admin_users.sample,
    weight: 0.28, # kg
    dimensions: "18x18x8", # cm
    categories: [ "Audio", "Electrónicos" ]
  },
  {
    name: "Altavoz Bluetooth Portátil",
    description: "Altavoz resistente al agua con sonido 360° y 20 horas de reproducción",
    price: "129.99",
    stock: 80,
    creator: admin_users.sample,
    weight: 0.6, # kg
    dimensions: "10x10x22", # cm
    categories: [ "Audio", "Electrónicos" ]
  },
  {
    name: "Zapatillas Running Elite",
    description: "Zapatillas profesionales para maratones con tecnología de amortiguación avanzada",
    price: "149.99",
    stock: 60,
    creator: admin_users.sample,
    weight: 0.4, # kg
    dimensions: "30x20x15", # cm
    categories: [ "Calzado", "Deportes" ]
  },
  {
    name: "Zapatos Formales Ejecutivos",
    description: "Zapatos de cuero genuino con diseño elegante para ocasiones formales",
    price: "179.99",
    stock: 45,
    creator: admin_users.sample,
    weight: 0.6, # kg
    dimensions: "32x20x12", # cm
    categories: [ "Calzado" ]
  },
  {
    name: "Cámara DSLR 4K Pro",
    description: "Cámara profesional de 36MP con grabación 4K y estabilización avanzada",
    price: "1299.99",
    stock: 30,
    creator: admin_users.sample,
    weight: 0.85, # kg
    dimensions: "15x10x8", # cm
    categories: [ "Fotografía", "Electrónicos" ]
  },
  {
    name: "Drone Fotográfico Avanzado",
    description: "Drone con cámara 4K, 40 minutos de vuelo y control de gestos",
    price: "899.99",
    stock: 15,
    creator: admin_users.sample,
    weight: 0.5, # kg
    dimensions: "30x30x10", # cm
    categories: [ "Fotografía", "Electrónicos" ]
  },
  {
    name: "Consola NextGen 8K",
    description: "La última generación de consolas con gráficos 8K y 1TB de almacenamiento SSD",
    price: "499.99",
    stock: 40,
    creator: admin_users.sample,
    weight: 3.5, # kg
    dimensions: "30x25x7", # cm
    categories: [ "Videojuegos", "Electrónicos" ]
  },
  {
    name: "Control Inalámbrico Ergonómico",
    description: "Control para consolas con diseño ergonómico y 30 horas de batería",
    price: "69.99",
    stock: 120,
    creator: admin_users.sample,
    weight: 0.3, # kg
    dimensions: "15x12x5", # cm
    categories: [ "Videojuegos", "Electrónicos" ]
  },
  {
    name: "Abrigo Impermeable Premium",
    description: "Abrigo de alta calidad con tecnología impermeable y forro térmico",
    price: "189.99",
    stock: 35,
    creator: admin_users.sample,
    weight: 1.2, # kg
    dimensions: "60x40x5", # cm (doblado)
    categories: [ "Ropa" ]
  },
  {
    name: "Conjunto Deportivo Profesional",
    description: "Conjunto de alto rendimiento con tejido transpirable y protección UV",
    price: "89.99",
    stock: 50,
    creator: admin_users.sample,
    weight: 0.5, # kg
    dimensions: "40x30x5", # cm (doblado)
    categories: [ "Ropa", "Deportes" ]
  },
  {
    name: "Robot de Cocina Multifunción",
    description: "12 funciones en un solo aparato: mezcla, cocina, tritura, amasa y más",
    price: "349.99",
    stock: 20,
    creator: admin_users.sample,
    weight: 8.5, # kg
    dimensions: "40x30x35", # cm
    categories: [ "Cocina", "Hogar" ]
  },
  {
    name: "Set de Cuchillos Profesionales",
    description: "Juego de 8 cuchillos de acero inoxidable alemán con bloque de madera",
    price: "199.99",
    stock: 25,
    creator: admin_users.sample,
    weight: 4.2, # kg
    dimensions: "35x25x10", # cm
    categories: [ "Cocina" ]
  },
  {
    name: "Kit de Yoga Completo",
    description: "Incluye esterilla antideslizante, bloques, correa y bolsa de transporte",
    price: "79.99",
    stock: 40,
    creator: admin_users.sample,
    weight: 2.5, # kg
    dimensions: "70x20x20", # cm
    categories: [ "Deportes", "Salud" ]
  },
  {
    name: "Bicicleta Estática Plegable",
    description: "Bicicleta estática con 8 niveles de resistencia y monitor digital",
    price: "249.99",
    stock: 15,
    creator: admin_users.sample,
    weight: 22.0, # kg
    dimensions: "100x45x110", # cm
    categories: [ "Deportes", "Salud" ]
  },
  {
    name: "Juego de Construcción Educativo",
    description: "Set de 500 piezas para construir mecanismos y estructuras avanzadas",
    price: "59.99",
    stock: 30,
    creator: admin_users.sample,
    weight: 1.8, # kg
    dimensions: "40x30x10", # cm
    categories: [ "Juguetes" ]
  },
  {
    name: "Muñeco Interactivo Educativo",
    description: "Muñeco que habla, canta y enseña diferentes idiomas con sensores táctiles",
    price: "49.99",
    stock: 45,
    creator: admin_users.sample,
    weight: 0.9, # kg
    dimensions: "35x20x15", # cm
    categories: [ "Juguetes" ]
  }
]

physical_products = []

physical_products_data.each do |product_data|
  # Extraer y eliminar el array de categorías del hash
  category_names = product_data.delete(:categories)

  # Crear el producto
  product = PhysicalProduct.create!(product_data)

  # Asignar las categorías adecuadas
  category_names.each do |category_name|
    if category_map[category_name]
      CategoriesProduct.create!(category: category_map[category_name], product: product)
    end
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
    purchase_date = random_date

    Purchase.create!(
      client: client,
      product: product,
      quantity: 1,
      total_price: product.price,
      created_at: purchase_date,
      updated_at: purchase_date
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

# Crear attachments (imágenes) para productos
puts "Creando attachments para productos..."

def create_attachment_for(product)
  attachment = Attachment.create!(record: product)

  # Adjuntar la imagen real desde fixtures/files
  if File.exist?(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'))
    attachment.image.attach(
      io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
    puts "  - Imagen adjuntada al producto #{product.name}"
  else
    puts "  - Advertencia: No se encontró test_image.jpg en fixtures/files"
  end

  attachment
end

# Crear attachments para productos digitales
digital_products.each do |product|
  rand(1..3).times do
    create_attachment_for(product)
  end
end

# Crear attachments para productos físicos
physical_products.each do |product|
  rand(2..4).times do
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
