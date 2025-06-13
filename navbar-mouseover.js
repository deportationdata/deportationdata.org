<script>
document.addEventListener("DOMContentLoaded", () => {
  // Pick up every dropdown in the navbar
  document.querySelectorAll(".navbar .dropdown").forEach((dd) => {
    // Show menu on mouse-enter
    dd.addEventListener("mouseenter", () => {
      dd.classList.add("show");
      dd.querySelector(".dropdown-menu").classList.add("show");
    });

    // Hide on mouse-leave
    dd.addEventListener("mouseleave", () => {
      dd.classList.remove("show");
      dd.querySelector(".dropdown-menu").classList.remove("show");
    });
  });
});
</script>