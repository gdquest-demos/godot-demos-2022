//@ts-check

function initCountdown() {
  const countdownElement = document.getElementById("countdown");

  if (!countdownElement) {
    return;
  }
  const dateStr = countdownElement.dataset.date || "";
  const parts = dateStr.match(/\d+/g) || [];

  if (parts.length < 3) {
    return;
  }

  const endDate = new Date(dateStr);

  const hour = 60 * 60 * 1000,
    day = hour * 24;

  const endTime = endDate.getTime();
  const timeOffsetUTC = endDate.getTimezoneOffset() * 60 * 1000;
  const endTimeUTC = endTime - timeOffsetUTC;

  const updateCountdown = () => {
    const now = new Date().getTime();
    const distance = endTimeUTC - now + timeOffsetUTC;
    const days = Math.floor(distance / day);

    if (days >= 3) {
      countdownElement.innerText = `${days} days left`;
    } else {
      let hours = Math.floor((distance % (day * 3)) / hour);
      if (hours > 1) {
        countdownElement.innerText = `${hours} hours left`;
      } else {
        countdownElement.innerText = `${hours} hour left`;
      }
    }
    if (distance < 0) {
      document.body.classList.remove("has-countdown");
    } else {
      document.body.classList.add("has-countdown");
    }
  };
  const intervalCallback = setInterval(updateCountdown, hour);
  updateCountdown();
}

initCountdown();
