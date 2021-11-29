<p align="center">
    <a href="https://sylius.com" target="_blank">
        <img src="https://demo.sylius.com/assets/shop/img/logo.png" />
    </a>
</p>

<h1 align="center">Sylius Standard Edition</h1>

<p align="center">This is Sylius Standard Edition repository for starting new projects.</p>

About
-----

Sylius is the first decoupled eCommerce platform based on [**Symfony**](http://symfony.com) and [**Doctrine**](http://doctrine-project.org). 
The highest quality of code, strong testing culture, built-in Agile (BDD) workflow and exceptional flexibility make it the best solution for application tailored to your business requirements. 
Enjoy being an eCommerce Developer again!

Powerful REST API allows for easy integrations and creating unique customer experience on any device.

We're using full-stack Behavior-Driven-Development, with [phpspec](http://phpspec.net) and [Behat](http://behat.org)

Documentation
-------------

Documentation is available at [docs.sylius.com](http://docs.sylius.com).

## Requirements
- [docker](https://www.docker.com/)
- [docker-compose](https://github.com/docker/compose)
- [make](https://www.gnu.org/software/make/manual/make.html)


Installation
------------

🚀 `make up` - spin up dev env  
🚀 `make up-prod` - spin up prod env no volume mounting just build image  
⚠️ (_Be aware that this can take some time. Monitor status by running make logs_)
☠️ `make down` - kill all apps  

[Example Terraform Infra config](/terraform)
----------------------------------
