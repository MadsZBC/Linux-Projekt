# Linux WordPress Installer

An automated WordPress installation script for Linux systems that handles the complete setup of WordPress, including NGINX, MariaDB, and PHP configuration.

## 🚀 Features

- **Automated Installation**: One-command installation of WordPress and all dependencies
- **Component Installation**:
  - MariaDB Database Server
  - PHP 8.2 with required extensions
  - NGINX Web Server
  - WordPress Latest Version
- **Interactive Configuration**: User-friendly menu for customizing installation settings
- **Comprehensive Logging**: Detailed logs for debugging and monitoring
- **Security**: Proper file permissions and secure database setup
- **Error Handling**: Robust error checking and validation

## 📋 Prerequisites

- Debian-based Linux distribution (Ubuntu, Debian)
- Root access or sudo privileges
- Internet connection
- Git (for cloning the repository)

## 🛠️ Quick Start

1. Clone and run the installer:

```bash
git clone https://github.com/MadsZBC/Linux-Projekt.git && bash Linux-Projekt/Installer.sh
```

## 📝 Configuration Options

The installer allows you to configure:

- Domain name
- Site title
- Database credentials
- WordPress admin details
- Debug mode

## 🔧 Installation Process

1. **Initial Setup**
   - System checks and validation
   - Package repository updates

2. **Database Setup**
   - MariaDB installation
   - Database and user creation
   - Secure permissions setup

3. **Web Server Setup**
   - NGINX installation
   - Virtual host configuration
   - PHP-FPM integration

4. **WordPress Setup**
   - Core files download
   - Configuration file creation
   - Initial WordPress setup

## 📊 Logging

The installer maintains detailed logs in the `logs` directory:
- `installation.log`: Main installation log
- `install_mariadb.log`: Database installation details
- `install_nginx.log`: Web server setup log
- `install_wordpress.log`: WordPress installation log
- `error.log`: Error messages
- `debug.log`: Detailed debugging information (when debug mode is enabled)

## 🔍 Troubleshooting

1. View logs through the installer menu
2. Enable debug mode for detailed logging
3. Check individual component logs in the `logs` directory

## 🛡️ Security Features

- Secure file permissions
- Database user isolation
- Configuration file protection
- Nginx security best practices

## 📚 Directory Structure

```
Linux-Projekt/
├── Installer.sh        # Main installation script
├── config.sh          # Configuration settings
├── scripts/
│   ├── install_mariadb.sh
│   ├── install_nginx.sh
│   ├── install_php.sh
│   ├── install_wordpress.sh
│   └── utils/
│       └── logging.sh
└── logs/              # Installation logs
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- WordPress Community
- NGINX Project
- MariaDB Project
- PHP Community

## 📧 Support

No issues at the moment.
No integration with a support system at the moment. And let's encrypt is not integrated at the moment.

For support, please open an issue in the GitHub repository or contact the maintainers.
