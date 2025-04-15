<script>
document.addEventListener("DOMContentLoaded", function () {
    const langItem = document.getElementById("languages-links-parent");

    const navItem = langItem.closest(".nav-item");
    navItem.parentNode.removeChild(navItem);

    const navbar = document.getElementById("navbarCollapse");
    navbar.appendChild(navItem);

    navItem.style.marginLeft = "auto";
    navItem.style.display = "flex";
    navItem.style.alignItems = "center";
  });
</script>
