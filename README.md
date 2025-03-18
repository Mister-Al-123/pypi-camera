# Component 2 - Task

<p>This is a starter Laravel package that includes BREEZE for authentication and is scaffolded with TailwindCSS. 
</p>
<p>
Please see the assignment brief for a full set of requirements
</p>
<p>
Once the project is cloned to your workspace. You will need to:
</p>
<ul>
<li><b>composer install</b> (to populate the vendor folder)</li>
<li><b>npm install && npm run dev</b> (to populate node_modules)</li>
<li><b>cp .env.example .env</b> to create your own .env file</li>
<li><b>php artisan key:generate</b> to add a key to the .env file</li>
</ul>

<br />
<br />
<b>NOTE (For development on Che)</b>

<p>As Che will force https connection the following file needs to be amended<br />

app/Providers/AppServiceProvider.php <br />

<code>public function boot(): void
    <br />&nbsp;{
        <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\URL::forceScheme('https'); 
    <br />&nbsp;}
</code>

In addition as Che routes the test site through a different port - Vite as a live css development tool will likely not connect,
rather than <em>npm run dev</em>, use <em>npm run build</em> to see the site running.

<h3>Tasks to do</h3>

<p>Please refer to the marking scheme. As a guide:</p>
<ul>
<li>Models for Product and  ProductType</li>
<li>CRUD operations using the correct HTTP Action</li>
<li>Good practice in the use of Model classes</li>
<li>Factories for Seeding data</li>
<li>Eloquent extensions to utilise Foreign Key relations</li>
<li>Different User Types</li>
<li>Gates and Middleware</li>
<li>Extending HttpRequests - Forms, Authorisation and Validation</li>
<li>Filtering /  Pagination to improve usability of large datasets</li>
<li>Good use of View Components (PHP Classes and Blade files)</li>
<li>File upload (images)</li>
</ul>

<p>Please remember that a professionl approach to development should be adopted. Commit often and follow good practice on writing code. Code should be readable and understandable.</p>



